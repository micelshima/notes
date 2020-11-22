<#
.Synopsis
  Notes App written in Powershell + WPF with SQLite database
.DESCRIPTION
	App for managing personal notes, snippets and knowledge database with a powerful search engine
	Search notes by various words by separating them with spaces
	Add new tags to available tag list writing new one in textbox above tag list
	Delete existing tags in available tag list writing existing tag in textbox above tag list
	Double clic a tag in tag list to assign tag to current note
	Delete exisisting note by clearing title or note textboxes and clicking save
	Mark notes as important to keep them in top
.PARAMETER database
	Open different database than default "Notes"
.EXAMPLE
	.\Notes.ps1 -database "More Notes"
	This will create the new database 'More Notes' (if it doesn't exist) and open it
.OUTPUTS
   None
.NOTES
   Author : Mikel V.
   version: 2.2
   Date   : 2020/07/29
.LINK
   http://sistemaswin.com
#>
param([string]$database = "Notes")
#Functions
function LoadXaml ($filename) {
	$XamlLoader = (New-Object System.Xml.XmlDocument)
	$XamlLoader.Load($filename)
	return $XamlLoader
}
function filter-grid ($text) {
	if ([bool]$text) {
		$filter = @()
		$objtext = $text -split " "
		$objtext | % { $filter += '$item -match "{0}"' -f [regex]::Escape($_) }
		$filter = $filter -join (" -and ")
		$lview.filter = { param ($item) invoke-expression $filter }
	}
	else { $lview.filter = $null }
	$lview.Refresh()
}
function listar-databases($databasename) {
	$TabControl.items.clear()
	$databasepath = "$PSscriptroot\..\databases\{0}.s3db" -f $databasename
	if (!(test-path $databasepath)) { copy-item "$PSscriptroot\template.s3db" $databasepath }
	get-childitem "$Psscriptroot\..\databases\*.s3db" | select fullname, basename, lastwritetime | sort LastWriteTime -desc | % { [void] $tabControl.Items.insert(0, $_.basename) }
	$tabControl.SelectedIndex = 1
	$tabControl.selecteditem = $databasename
	$window.Title = 'SistemasWin | Notes App | {0}' -f [string]$tabControl.selecteditem
	return $databasepath
}
function listar-tags() {
	$OverlayListBoxTags.Items.clear()
	if ($Overlaytags.text -eq $null -or $Overlaytags.text -eq '') { $qry = "select tag from Tags order by tag" }
	else {
		$Overlaytags.text.split(',') | % {
			if ($str -ne $null) { $str += ',' }
			$str += "'$_'"
		}
		$qry = "select tag from Tags where Tag not in ({0}) order by tag COLLATE NOCASE" -f $str
	}
	$rs = read-SQLite $database $qry
	$rs | % { [void] $OverlayListBoxTags.Items.Add($_.tag) }

}
function listar-notas() {
	$qry = "select * from notes order by important desc,datetime desc"
	$data = [System.Collections.ArrayList]@()
	read-SQLite $database $qry | % {
		$data.add([pscustomobject]@{
				id        = $_.id
				title     = $_.title
				note      = $_.note
				tags      = $_.tags
				datetime  = $_.datetime.tostring("dd/MM/yyyy HH:mm:ss")
				important = $_.important
			})
	}
	$global:lview = [System.Windows.Data.ListCollectionView]$data
	$Datagrid.itemssource = $lview
}
##main##
"results" | % { if (!(test-path "$PSScriptRoot\..\$_")) { New-item -ItemType Directory -path "$PSScriptRoot\..\$_" | out-null } }
import-module "$PSscriptRoot\..\SQliteModule"
if (!(test-path "$PSScriptRoot\..\databases")) { New-item -ItemType Directory -path "$PSScriptRoot\..\databases" | out-null }
# Add shared_assemblies
Add-Type -assemblyName WindowsBase
Add-Type -assemblyName PresentationCore
Add-Type -assemblyName PresentationFramework
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.dll")       				| out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\System.Windows.Interactivity.dll") 	| out-null
#Load Panel
$xaml = LoadXaml "$PSscriptRoot\WPF.xaml"
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$form = [Windows.Markup.XamlReader]::Load($reader)
$xaml.selectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | % {
	New-Variable  -Name $_.Name -Value $Form.FindName($_.Name) -Force
}

$database = listar-databases $database
$null = listar-notas

$TabControl.Add_SelectionChanged( {

		if ([bool]$TabControl.selecteditem) {
			$global:database = "$PSscriptroot\..\databases\{0}.s3db" -f [string]$TabControl.selecteditem
			$window.Title = 'SistemasWin | Notes App | {0}' -f [string]$TabControl.selecteditem
			$null = listar-notas
			filter-grid $TextBoxBuscador.text
		}

	})
$ButtonNewDatabase.Add_Click( {
		switch ($TextboxNewDatabase.visibility) {
			"Collapsed" { $TextboxNewDatabase.visibility = "Visible"; break }
			"Visible" {
				if ($TextboxNewDatabase.text -ne "" ) {
					$global:database = listar-databases $TextboxNewDatabase.text
					$TextboxNewDatabase.text = ""
				}
				$TextboxNewDatabase.visibility = "Collapsed"
			}
		}
	})
$TextboxNewDatabase.Add_KeyDown( {
		if ($_.Key -eq "Enter" -and $TextboxNewDatabase.text -ne "") {
		 $global:database = listar-databases $TextboxNewDatabase.text
		 $TextboxNewDatabase.text = ""
		 $TextboxNewDatabase.visibility = "Collapsed"
		}
	})

$ButtonBuscador.Add_Click( {
		filter-grid $TextBoxBuscador.text
	})
$TextBoxBuscador.Add_TextChanged( {
		filter-grid $TextBoxBuscador.text
	})
$Buttonexportcsv.Add_Click( {
		$lview | export-csv -path "$Psscriptroot\..\results\Notes.csv" -notypeInformation -delimiter "`t" -encoding unicode
		start-process "$Psscriptroot\..\results\notes.csv"

	})
$ButtonSave.Add_Click( {
		$Overlaytitle.text = $Overlaytitle.text -replace ("'", "''")
		$Overlaynote.text = $Overlaynote.text -replace ("'", "''")
		if ($global:id -eq $null) {
			if ([bool]$Overlaytitle.text -ne $false) {
				$qry = "insert into Notes(title,note,tags,datetime,important) values('{0}','{1}','{2}','{3:yyyy-MM-dd HH:mm:ss}',{4})" -f $Overlaytitle.text, $Overlaynote.text, $Overlaytags.text, (get-date $OverlayDate.text), [int]$overlayimportant.ischecked
			}
		}
		else {
			if ([bool]$Overlaytitle.text -ne $false) {
				$qry = "update notes set title='{0}', note='{1}', tags='{2}',datetime='{3:yyyy-MM-dd HH:mm:ss}',important={4} where id={5}" -f $Overlaytitle.text, $Overlaynote.text, $Overlaytags.text, (get-date $OverlayDate.text), [int]$overlayimportant.ischecked, $global:id
			}
			#if title or note becomes empty I suppose you want to delete the entry
			else { $qry = "delete from notes where id={0}" -f $global:id }
		}
		#write-host $qry
		Write-SQlite $database $qry
		$overlay.visibility = "Hidden"
		$null = listar-notas
		filter-grid $TextBoxBuscador.text
	})
$ButtonClose.Add_Click( {
		$overlay.visibility = "Hidden"

	})
$ButtonAddNew.Add_Click( {
		$global:id = $null
		$overlay.visibility = "Visible"
		$Overlaytitle.text = $null
		$OverlayDate.text = '{0:dd/MM/yyyy HH:mm:ss}' -f (get-date)
		$Overlaytags.text = $null
		$Overlaynote.text = $null
		$Overlayimportant.ischecked = $false
		$null = listar-tags
	})
$OverlayNewTag.Add_KeyDown( {
		if ($_.Key -eq "Enter") {
			$qry = "select tag from Tags where Tag ='{0}'" -f $OverlayNewTag.text
			$rs = read-SQLite $database $qry
			if ($rs -eq $null) { $qry = "insert into tags(tag) values('{0}')" -f $OverlayNewTag.text }
			else { $qry = "delete from tags where tag='{0}'" -f $OverlayNewTag.text }
			Write-SQlite $database $qry
			$null = listar-tags
			$OverlayNewTag.text = $null
		}
	})
$OverlayListBoxTags.Add_MouseDoubleClick( {
		if ([bool]$Overlaytags.text -ne $false) { $Overlaytags.text = $Overlaytags.text + ',' }
		$Overlaytags.text = $Overlaytags.text + $OverlayListBoxTags.SelectedItem
		$null = listar-tags
	})
[System.Windows.RoutedEventHandler]$EventonDataGrid = {
	$button = $_.OriginalSource.Name
	switch ($button) {
		"Edit" {
			$global:id = $Datagrid.CurrentItem.id
			$overlay.visibility = "Visible"
			$Overlaytitle.text = $Datagrid.CurrentItem.title
			$OverlayDate.text = $Datagrid.CurrentItem.datetime
			$Overlaytags.text = $Datagrid.CurrentItem.tags
			$Overlaynote.text = $Datagrid.CurrentItem.note
			$Overlayimportant.IsChecked = [bool]$datagrid.currentItem.important
			$null = listar-tags
		}
	}
}
$Datagrid.AddHandler([System.Windows.Controls.Button]::ClickEvent, $EventonDataGrid)
#show the Form
$form.ShowDialog() | Out-Null