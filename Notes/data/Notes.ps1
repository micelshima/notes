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
	$qry="select tag from Tags where Tag not in ({0}) order by tag" -f $str
	}
$rs=read-SQLite $database $qry
$rs|%{[void] $ListBoxtags.Items.Add($_.tag)}
}#fin listartags
Function listarnotas()
{
$ListViewsearch.Items.clear()
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
	[void] $ListViewsearch.Items.Add($itm)
	}
$global:id_list=$id_list.substring(1)
}#fin if ne null
#$labelcount.text=$ListViewsearch.Items.count

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
$Form1.ClientSize = new-object System.Drawing.Size(680, 525)
$Form1.text="SistemasWin | Notes"
$Icon= New-Object system.drawing.icon ("$scriptPath\notes.ico")
$Form1.Icon = $Icon
$Form1.backcolor=[System.Drawing.Color]::DarkSlateGray
$Form1.WindowState = "Normal"    # Maximized, Minimized, Normal
$Form1.SizeGripStyle = "Hide"    # Auto, Hide, Show
#$Form1.ShowInTaskbar = $False
#$Form1.TopMost = $true
#$Form1.KeyPreview = $True
$Form1.Add_Resize({
	#relocate all the objects
	$pictureBox.Location = new-object System.Drawing.Point(($Form1.ClientSize.width/2 - 300/2),0)
	$tabControl1.Size = new-object System.Drawing.Size(($Form1.ClientSize.Width -10),($Form1.ClientSize.height -80))
	$combosearch.Location = New-Object System.Drawing.Point(($tabControl1.size.width/2 -345/2 -75),10)
	$textboxsearch.Location = new-object System.Drawing.Point(($tabControl1.size.width/2 -345/2),10)
	$buttonsearch.Location = new-object System.Drawing.Point(($tabControl1.size.width/2 +345/2 +1),10)
	$labelcount.Location = new-object System.Drawing.Point(($tabControl1.size.width/2 +345/2 + 30),13)
	$ListViewsearch.Size = New-Object System.Drawing.Size(($tabControl1.size.width -30),($tabControl1.size.height -80))
	$columnB.Width = ($ListViewsearch.Size.width -22)
	$buttonexport.Location = New-Object System.Drawing.Point(($tabControl1.size.width -20),($tabControl1.size.height -41))
	$textboxnote.Size = new-object System.Drawing.Size(($tabControl1.size.width -30),($tabControl1.size.height -135))
	$textboxtags.Location = new-object System.Drawing.Point(10,($tabControl1.size.height -95))
	$textboxtags.Size = new-object System.Drawing.Size(($tabControl1.size.width -30),22)
	$buttonedit.Location = new-object System.Drawing.Point(($tabControl1.size.width -100),($tabControl1.size.height -60))
	$textboxnewtitle.Size = new-object System.Drawing.Size(($tabControl1.size.width -160),20)	
	$textboxnewnote.Size = new-object System.Drawing.Size(($tabControl1.size.width -160),($tabControl1.size.height -135))
	$textboxaddtag.Location = new-object System.Drawing.Point(($textboxnewnote.size.width+15),10)
	$ListBoxtags.Location = New-Object System.Drawing.Point(($textboxnewnote.size.width+15),35) 
	$ListBoxtags.Size = New-Object System.Drawing.Size(125,($tabControl1.size.height -130))
	$textboxselectedtags.Location = new-object System.Drawing.Point(10,($tabControl1.size.height -95))
	$textboxselectedtags.Size = new-object System.Drawing.Size(($tabControl1.size.width -30),22)
	$buttondelete.Location = new-object System.Drawing.Point(($tabControl1.size.width -190),($tabControl1.size.height -60))
	$buttonnew.Location = new-object System.Drawing.Point(($tabControl1.size.width -100),($tabControl1.size.height -60))
})	
#cabecera
$base64ImageString="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"
$imageBytes = [Convert]::FromBase64String($base64ImageString)
$ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
$ms.Write($imageBytes, 0, $imageBytes.Length);
$logo = [System.Drawing.Image]::FromStream($ms, $true)
$pictureBox = new-object System.Windows.Forms.PictureBox
$pictureBox.Location = new-object System.Drawing.Point(($Form1.ClientSize.width/2 - 300/2),0)
$pictureBox.Size = new-object System.Drawing.Size(300,95)
$pictureBox.TabStop = $false
$pictureBox.image=$logo
$Form1.Controls.Add($pictureBox)

#Tabs
$tabControl1 = New-Object System.Windows.Forms.TabControl
$tabControl1.DataBindings.DefaultDataSourceUpdateMode = 0
$tabControl1.Location = new-object System.Drawing.Point(5,75)
$tabControl1.Name = "tabControl1"
$tabControl1.SelectedIndex = 0
$tabControl1.Font = $css_buttonery.font
$tabControl1.ShowToolTips = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$tabControl1.Size = new-object System.Drawing.Size(($Form1.ClientSize.Width -10),($Form1.ClientSize.height -80))
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
$combosearch.Location = New-Object System.Drawing.Point(($tabControl1.size.width/2 -345/2 -75),10)
$combosearch.Size = New-Object System.Drawing.Size(75,20) 
$combosearch.Font = $css_textbox.Bigfont
$combosearch.Name = "SearchOptions"
$combosearch.items.addrange($searchoptions)
$combosearch.text=$searchoptions[0]
$tabPage1.Controls.Add($combosearch)
#textbox
$textboxsearch = New-Object System.Windows.Forms.textbox
$textboxsearch.Location = new-object System.Drawing.Point(($tabControl1.size.width/2 -345/2),10)
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
$buttonsearch.Location = new-object System.Drawing.Point(($tabControl1.size.width/2 +345/2 +1),10)
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
$labelcount.Location = new-object System.Drawing.Point(($tabControl1.size.width/2 +345/2 + 30),13)
$labelcount.Size = new-object System.Drawing.Size(65,20)
$labelcount.Font = $css_textbox.Bigfont
$labelcount.Forecolor=[System.Drawing.Color]::silver
$tabPage1.controls.add($labelcount)

$ListViewsearch = New-Object System.Windows.Forms.ListView 
$ListViewsearch.Location = New-Object System.Drawing.point(10,40) 
$ListViewsearch.Size = New-Object System.Drawing.Size(($tabControl1.size.width -30),($tabControl1.size.height -80))
$ListViewsearch.MultiSelect = 0
$ListViewsearch.FullRowSelect = $true
$ListViewsearch.GridLines = $true
$ListViewsearch.view="Details"
$ListViewsearch.HeaderStyle="None" #'none', 'Nonclickable', 'Clickable'
$columnA = New-Object System.Windows.Forms.ColumnHeader
$columnA.name = "A"
$columnA.Text = "id"
$columnA.Width = 0
$columnB = New-Object System.Windows.Forms.ColumnHeader
$columnB.name = "B"
$columnB.Text = "title"
$columnB.Width = ($ListViewsearch.Size.width -22)
$ListViewsearch.Columns.Add($columnA)|out-null
$ListViewsearch.Columns.Add($columnB)|out-null
$ListViewsearch.Font = $css_textbox.Smallfont
$ListViewsearch.borderstyle = 2 #0=sin borde, 2=borde 1=hundido
$val=listarnotas
$tabPage1.Controls.Add($ListViewsearch)
$ListViewsearch.add_doubleclick({
	$qry="select * from notes where id='{0}'" -f $ListViewsearch.SelectedItems[0].SubItems[0].Text
	$rs=read-SQLite $database $qry
	$textboxtitle.text=$rs.title
	$global:id=$rs.id
	$textboxnote.text=$rs.note
	$textboxtags.text=$rs.tags
	$tabControl1.selectedtab=$tabPage2
	
})
$buttonexport = New-Object System.Windows.Forms.Button
$buttonexport.Location = New-Object System.Drawing.point(($tabControl1.size.width -20),($tabControl1.size.height -41))
$buttonexport.Size = new-object System.Drawing.Size(10,10)
$buttonexport.BackColor = [System.Drawing.Color]::Silver
$buttonexport.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonexport.Font = new-object System.Drawing.Font("Webdings",5)
$buttonexport.text="4"
$tabPage1.controls.add($buttonexport)
$buttonexport.Add_Click({
	$qry="select * from notes where id in ({0})" -f $global:id_list
	$rs=read-SQLite $database $qry	
	$rs|select title,note,tags,datetime|export-clixml "$scriptPath\..\NotesExport.xml"
})
$ToolTip = New-Object System.Windows.Forms.ToolTip
$ToolTip.BackColor = [System.Drawing.Color]::LightGoldenrodYellow
$ToolTip.IsBalloon = $true
$ToolTip.InitialDelay = 500
$ToolTip.ReshowDelay = 500
$ToolTip.SetToolTip($buttonexport, "Export current notes to xml file.") 
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
$buttonedit.Location = new-object System.Drawing.Point(($tabControl1.size.width -100),($tabControl1.size.height -60))
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
	$qry="insert into tags(tag) values('{0}')" -f $textboxaddtag.text
	Write-SQlite $database $qry
	$val=listartags
	$textboxaddtag.text=$null
	}
})
$ListBoxtags = New-Object System.Windows.Forms.ListBox 
$ListBoxtags.Location = New-Object System.Drawing.Point(($textboxnewnote.size.width+15),35) 
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
$buttondelete.Location = new-object System.Drawing.Point(($tabControl1.size.width -190),($tabControl1.size.height -60))
$buttondelete.Size = new-object System.Drawing.Size(80,22)
$buttondelete.Font = $css_buttonery.font
$buttondelete.text="Delete"
$buttondelete.visible=$false
$tabPage3.controls.add($buttondelete)
$buttondelete.Add_Click({
	$qry="delete from notes where id={0}" -f $editingID
	Write-SQlite $database $qry
	$global:editingID=$null
	$textboxnewtitle.text=$textboxnewnote.text=$textboxselectedtags.text=$null #limpio los campos
	$val=listarnotas
	$val=listartags
	$buttondelete.visible=$false
	$tabControl1.selectedtab=$tabPage1
})
$buttonnew = New-Object System.Windows.Forms.Button
$buttonnew.Location = new-object System.Drawing.Point(($tabControl1.size.width -100),($tabControl1.size.height -60))
$buttonnew.Size = new-object System.Drawing.Size(80,22)
$buttonnew.Font = $css_buttonery.font
$buttonnew.text="Save"
$tabPage3.controls.add($buttonnew)
$buttonnew.Add_Click({
	$textboxnewtitle.text=$textboxnewtitle.text -replace("'","''")
	$textboxnewnote.text=$textboxnewnote.text -replace("'","''")
	if ($editingID -eq $null){$qry= "insert into Notes(title,note,tags) values('{0}','{1}','{2}')" -f $textboxnewtitle.text,$textboxnewnote.text,$textboxselectedtags.text}
	else{$qry="update notes set title='{0}', note='{1}', tags='{2}' where id={3}" -f $textboxnewtitle.text,$textboxnewnote.text, $textboxselectedtags.text,$editingID}
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
