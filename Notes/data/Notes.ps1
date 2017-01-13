#Mikel V. 03/11/2014
Function listartags()
{
$ListBoxtags.Items.clear()
	if ($textboxselectedtags.text -eq $null -or $textboxselectedtags.text -eq ''){$qry="select tag from Tags order by tag"}
	else
	{
	$textboxselectedtags.text.split(',')|%{
		if ($str -ne $null){$str+=','}
		$str+="'$_'"
		}
	$qry="select tag from Tags where Tag not in ($str) order by tag"
	}
$rs=read-SQLite $database $qry
$rs|%{[void] $ListBoxtags.Items.Add($_.tag)}
}#fin listartags
Function listarnotas()
{
$ListBoxsearch.Items.clear()
	if($textboxsearch.text -eq $null -or $textboxsearch.text -eq ''){$qry="select * from notes order by datetime desc"}
	else
	{
		switch($combosearch.selecteditem)
		{
		"All"{
			$textboxsearch.text.split(' ')|%{
				if ($str1 -ne $null){$str1+=' and '}
				$str1+="(note like '%$_%' or tags like '%$_%' or title like '%$_%')"		
				}			
			}
		"Notes"{
			$textboxsearch.text.split(' ')|%{
				if ($str1 -ne $null){$str1+=' and '}
				$str1+="(note like '%$_%' or title like '%$_%')"		
				}
			}
		"Tags"{
			$textboxsearch.text.split(' ')|%{
				if ($str1 -ne $null){$str1+=' and '}
				$str1+="tags like '%$_%'"		
				}
			}
		}
	$qry="select title,id from notes where $str1 order by datetime desc"
	}
$rs=read-SQLite $database $qry
if ($rs -ne $null)
{
$labelcount.text=$rs.count
$id_list=$null
	$rs|%{
	$id_list="$id_list,$($_.id)"
	$itm = New-Object System.Windows.Forms.ListViewItem([string]$_.id)
	$itm.SubItems.Add([string]$_.title)
	[void] $ListBoxsearch.Items.Add($itm)
	}
$global:id_list=$id_list.substring(1)
}#fin if ne null
#$labelcount.text=$ListBoxsearch.Items.count

}#fin function

### main ###
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$database = "$scriptPath\notes.s3db"
import-module "$scriptPath\SQliteModule"
#Formulario
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::loadwithpartialname("System.Drawing")
[System.Windows.Forms.Application]::EnableVisualStyles()
#cargo la hoja de estilos
. "$scriptPath\css.ps1"
$Form1 = New-Object System.Windows.Forms.Form
$Form1.ClientSize = "600, 520"
$Form1.text="SistemasWin | Notes"
$Icon= New-Object system.drawing.icon ("$scriptPath\notes.ico")
$Form1.Icon = $Icon
$Form1.backcolor=[System.Drawing.Color]::GhostWhite
#$Form1.MinimizeBox = $False
$Form1.MaximizeBox = $False
$Form1.WindowState = "Normal"    # Maximized, Minimized, Normal
$Form1.SizeGripStyle = "Hide"    # Auto, Hide, Show
#$Form1.ShowInTaskbar = $False
#$Form1.TopMost = $true
#$Form1.KeyPreview = $True
#cabecera
$pictureBox = new-object System.Windows.Forms.PictureBox
$pictureBox.Location = new-object System.Drawing.Point(0,0)
$pictureBox.Size = new-object System.Drawing.Size($Form1.ClientSize.Width,95)
$pictureBox.TabStop = $false
$pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$pictureBox.Load("$scriptPath\cabecera.png")
$Form1.Controls.Add($pictureBox)
#Tabs
$tabControl1 = New-Object System.Windows.Forms.TabControl
$tabControl1.DataBindings.DefaultDataSourceUpdateMode = 0
$tabControl1.Location = new-object System.Drawing.Point(1,95)
$tabControl1.Name = "tabControl1"
$tabControl1.SelectedIndex = 0
$tabControl1.Font = $css_buttonery.font
$tabControl1.ShowToolTips = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$tabControl1.Size = new-object System.Drawing.Size($Form1.ClientSize.Width,($Form1.ClientSize.height -95))
$tabControl1.TabIndex = 2
$form1.Controls.Add($tabControl1)
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Search"
$tabControl1.Controls.Add($tabPage1)
$tabPage2 = New-Object System.Windows.Forms.TabPage
$tabPage2.Text = "Note"
$tabControl1.Controls.Add($tabPage2)
$tabPage3 = New-Object System.Windows.Forms.TabPage
$tabPage3.Text = "New"
$tabControl1.Controls.Add($tabPage3)
####TAB 1 CONTENT (SEARCH)
#combo
$searchoptions="All","Notes","Tags"
$combosearch=New-Object System.Windows.Forms.ComboBox
$combosearch.Location = New-Object System.Drawing.Point(80,10) 
$combosearch.Size = New-Object System.Drawing.Size(75,20) 
$combosearch.Font = $css_textbox.Bigfont
$combosearch.Name = "SearchOptions"
$combosearch.items.addrange($searchoptions)
$combosearch.text=$searchoptions[0]
$tabPage1.Controls.Add($combosearch)
#textbox
$textboxsearch = New-Object System.Windows.Forms.textbox
$textboxsearch.Location = new-object System.Drawing.Point(155,10)
$textboxsearch.Size = new-object System.Drawing.Size(345,20)
$textboxsearch.Font = $css_textbox.Bigfont
$textboxsearch.borderstyle = 2 #0=sin borde, 1=borde 2=hundido
$tabPage1.controls.add($textboxsearch)
$textboxsearch.Add_KeyDown({
	if ($_.KeyCode -eq "Enter") 
    {
	$val=listarnotas
	}
})
$buttonsearch = New-Object System.Windows.Forms.Button
$buttonsearch.Location = new-object System.Drawing.Point(500,10)
$buttonsearch.Size = new-object System.Drawing.Size(20,22)
$buttonsearch.BackColor = [System.Drawing.Color]::CadetBlue
$buttonsearch.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonsearch.Font = new-object System.Drawing.Font("Webdings",14)
$buttonsearch.text="4"
$tabPage1.controls.add($buttonsearch)
$buttonsearch.Add_Click({ 
	$val=listarnotas
})
$ToolTip0 = New-Object System.Windows.Forms.ToolTip
$ToolTip0.BackColor = [System.Drawing.Color]::LightGoldenrodYellow
$ToolTip0.IsBalloon = $true
$ToolTip0.InitialDelay = 500
$ToolTip0.ReshowDelay = 500
$ToolTip0.SetToolTip($buttonsearch, "Search!") 
$labelcount= New-Object System.Windows.Forms.label
$labelcount.Location = new-object System.Drawing.Point(550,13)
$labelcount.Size = new-object System.Drawing.Size(65,20)
$labelcount.Font = $css_textbox.Bigfont
$labelcount.Forecolor="silver"
$tabPage1.controls.add($labelcount)

$ListBoxsearch = New-Object System.Windows.Forms.ListView 
$ListBoxsearch.Location = New-Object System.Drawing.Size(10,40) 
$ListBoxsearch.Size = New-Object System.Drawing.Size(($tabControl1.size.width -30),($tabControl1.size.height -80))
$ListBoxsearch.MultiSelect = 0
$ListBoxsearch.FullRowSelect = $true
$ListBoxsearch.GridLines = $true
$ListBoxsearch.view="Details"
$ListBoxsearch.HeaderStyle="None" #'none', 'Nonclickable', 'Clickable'
$ListBoxsearch.Columns.Add("id", 0, "left")|out-null
$ListBoxsearch.Columns.Add("title",($ListBoxsearch.Size.width -22), "left")|out-null
$ListBoxsearch.Font = $css_textbox.Smallfont
$ListBoxsearch.borderstyle = 2 #0=sin borde, 2=borde 1=hundido
$val=listarnotas
$tabPage1.Controls.Add($ListBoxsearch)
$ListBoxsearch.add_doubleclick({
	$qry="select * from notes where id='$($ListBoxsearch.SelectedItems[0].SubItems[0].Text)'"
	$rs=read-SQLite $database $qry
	$textboxtitle.text=$rs.title
	$global:id=$rs.id
	$textboxnote.text=$rs.note
	$textboxtags.text=$rs.tags
	$tabControl1.selectedtab=$tabPage2
	
})
$buttonexport = New-Object System.Windows.Forms.Button
$buttonexport.Location = New-Object System.Drawing.Size(($tabControl1.size.width -20),($tabControl1.size.height -41))
$buttonexport.Size = new-object System.Drawing.Size(10,10)
$buttonexport.BackColor = [System.Drawing.Color]::Silver
$buttonexport.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonexport.Font = new-object System.Drawing.Font("Webdings",5)
$buttonexport.text="4"
$tabPage1.controls.add($buttonexport)
$buttonexport.Add_Click({
	$qry="select * from notes where id in ($($global:id_list))"
	$rs=read-SQLite $database $qry
	out-file "$scriptPath\..\NotesExport.txt" -input "NOTES EXPORT: $qry"
	out-file "..\NotesExport.txt" -input "---------------------" -append
	$rs|%{
		out-file "$scriptPath\..\NotesExport.txt" -input "TITLE: $($_.title) ($($_.datetime))" -append
		out-file "$scriptPath\..\NotesExport.txt" -input "NOTE: $($_.note)" -append
		out-file "$scriptPath\..\NotesExport.txt" -input "TAGS: $($_.tags)" -append
		out-file "$scriptPath\..\NotesExport.txt" -input "---------------------" -append
	}
})
$ToolTip = New-Object System.Windows.Forms.ToolTip
$ToolTip.BackColor = [System.Drawing.Color]::LightGoldenrodYellow
$ToolTip.IsBalloon = $true
$ToolTip.InitialDelay = 500
$ToolTip.ReshowDelay = 500
$ToolTip.SetToolTip($buttonexport, "Export current notes to TXT file.") 
####TAB 2 CONTENT (NOTE)
$textboxtitle = New-Object System.Windows.Forms.label
$textboxtitle.Location = new-object System.Drawing.Point(10,10)
$textboxtitle.Size = new-object System.Drawing.Size(($tabControl1.size.width -30),20)
$textboxtitle.Font = $css_textbox.Normalfont
$tabPage2.controls.add($textboxtitle)
$textboxnote = New-Object System.Windows.Forms.textbox
$textboxnote.Location = new-object System.Drawing.Point(10,35)
$textboxnote.Size = new-object System.Drawing.Size(($tabControl1.size.width -30),($tabControl1.size.height -135))
$textboxnote.Multiline =$true
$textboxnote.ReadOnly =$true
$textboxnote.scrollbars ='Vertical'
$textboxnote.Font = $css_textbox.Normalfont
$textboxnote.borderstyle = 2 #0=sin borde, 1=borde 2=hundido
$tabPage2.controls.add($textboxnote)
$textboxtags = New-Object System.Windows.Forms.textbox
$textboxtags.Location = new-object System.Drawing.Point(10,($tabControl1.size.height -95))
$textboxtags.Size = new-object System.Drawing.Size(($tabControl1.size.width -30),22)
$textboxtags.Multiline =$true
$textboxtags.ReadOnly =$true
$textboxtags.scrollbars ='Vertical'
$textboxtags.Font = $css_textbox.Smallfont
$textboxtags.borderstyle = 2 #0=sin borde, 1=borde 2=hundido
$tabPage2.controls.add($textboxtags)
$buttonedit = New-Object System.Windows.Forms.Button
$buttonedit.Location = new-object System.Drawing.Point(500,($tabControl1.size.height -60))
$buttonedit.Size = new-object System.Drawing.Size(80,22)
$buttonedit.Font = $css_buttonery.font
$buttonedit.text="Edit"
$tabPage2.controls.add($buttonedit)
$buttonedit.Add_Click({
	$textboxnewtitle.text=$textboxtitle.text
	$textboxnewnote.text=$textboxnote.text
	$global:editingID=$id
	$buttondelete.visible=$true
	$textboxselectedtags.text=$textboxtags.text
	$val=listartags
	$tabControl1.selectedtab=$tabPage3
})
####TAB 3 CONTENT (NEW)
$textboxnewtitle = New-Object System.Windows.Forms.textbox
$textboxnewtitle.Location = new-object System.Drawing.Point(10,10)
$textboxnewtitle.Size = new-object System.Drawing.Size(($tabControl1.size.width -160),20)
$textboxnewtitle.Font = $css_textbox.Normalfont
$textboxnewtitle.borderstyle = 2 #0=sin borde, 1=borde 2=hundido
$tabPage3.controls.add($textboxnewtitle)
$textboxnewnote = New-Object System.Windows.Forms.textbox
$textboxnewnote.Location = new-object System.Drawing.Point(10,35)
$textboxnewnote.Size = new-object System.Drawing.Size(($tabControl1.size.width -160),($tabControl1.size.height -135))
$textboxnewnote.Multiline =$true
$textboxnewnote.AllowDrop =$true
$textboxnewnote.scrollbars ='Vertical'
$textboxnewnote.Font = $css_textbox.Normalfont
$textboxnewnote.borderstyle = 2 #0=sin borde, 1=borde 2=hundido
$tabPage3.controls.add($textboxnewnote)
$textboxaddtag = New-Object System.Windows.Forms.textbox
$textboxaddtag.Location = new-object System.Drawing.Point(($textboxnewnote.size.width+15),10)
$textboxaddtag.Size = new-object System.Drawing.Size(125,20)
$textboxaddtag.Font = $css_textbox.Normalfont
$textboxaddtag.borderstyle = 2 #0=sin borde, 1=borde 2=hundido
$tabPage3.controls.add($textboxaddtag)
$textboxaddtag.Add_KeyDown({
	if ($_.KeyCode -eq "Enter" -and $textboxaddtag.text -ne $null) 
    {
	$qry="insert into tags(tag) values('$($textboxaddtag.text)')"
	Write-SQlite $database $qry
	$val=listartags
	$textboxaddtag.text=$null
	}
})
$ListBoxtags = New-Object System.Windows.Forms.ListBox 
$ListBoxtags.Location = New-Object System.Drawing.Size(($textboxnewnote.size.width+15),35) 
$ListBoxtags.Size = New-Object System.Drawing.Size(125,($tabControl1.size.height -130))
$ListBoxtags.Font = $css_textbox.Smallfont
$ListBoxtags.borderstyle = 1 #0=sin borde, 2=borde 1=hundido
$val=listartags
$tabPage3.Controls.Add($ListBoxtags)
$ListBoxtags.add_doubleclick({	
	if ($textboxselectedtags.text -ne ''){$textboxselectedtags.text=$textboxselectedtags.text + ','}
	$textboxselectedtags.text=$textboxselectedtags.text + $ListBoxtags.SelectedItem
	$val=listartags
})
$textboxselectedtags = New-Object System.Windows.Forms.textbox
$textboxselectedtags.Location = new-object System.Drawing.Point(10,($tabControl1.size.height -95))
$textboxselectedtags.Size = new-object System.Drawing.Size(($tabControl1.size.width -30),22)
$textboxselectedtags.Multiline =$false
$textboxselectedtags.Font = $css_textbox.Smallfont
$textboxselectedtags.borderstyle = 2 #0=sin borde, 1=borde 2=hundido
$tabPage3.controls.add($textboxselectedtags)
$buttondelete = New-Object System.Windows.Forms.Button
$buttondelete.Location = new-object System.Drawing.Point(410,($tabControl1.size.height -60))
$buttondelete.Size = new-object System.Drawing.Size(80,22)
$buttondelete.Font = $css_buttonery.font
$buttondelete.text="Delete"
$buttondelete.visible=$false
$tabPage3.controls.add($buttondelete)
$buttondelete.Add_Click({
	$qry="delete from notes where id=$editingID"
	Write-SQlite $database $qry
	$global:editingID=$null
	$textboxnewtitle.text=$textboxnewnote.text=$textboxselectedtags.text=$null #limpio los campos
	$val=listarnotas
	$val=listartags
	$buttondelete.visible=$false
	$tabControl1.selectedtab=$tabPage1
})
$buttonnew = New-Object System.Windows.Forms.Button
$buttonnew.Location = new-object System.Drawing.Point(500,($tabControl1.size.height -60))
$buttonnew.Size = new-object System.Drawing.Size(80,22)
$buttonnew.Font = $css_buttonery.font
$buttonnew.text="Save"
$tabPage3.controls.add($buttonnew)
$buttonnew.Add_Click({
	$textboxnewtitle.text=$textboxnewtitle.text -replace("'","''")
	$textboxnewnote.text=$textboxnewnote.text -replace("'","''")
	if ($editingID -eq $null){$qry= "insert into Notes(title,note,tags) values('$($textboxnewtitle.text)','$($textboxnewnote.text)','$($textboxselectedtags.text)')"}
	else{$qry="update notes set title='$($textboxnewtitle.text)', note='$($textboxnewnote.text)', tags='$($textboxselectedtags.text)' where id=$editingID"}
	Write-SQlite $database $qry
	
	$global:editingID=$null
	$textboxnewtitle.text=$textboxnewnote.text=$textboxselectedtags.text=$null  #limpio los campos
	$val=listarnotas
	$val=listartags
	$buttondelete.visible=$false
	$tabControl1.selectedtab=$tabPage1
	})
#muestro el formulario
[System.Windows.Forms.Application]::Run($Form1)
