-- Move the iTunes selected files to a new path
-- Created to move my iTunes U media files to the external hard drive. But works with any kind of file.

-- Used to show the script progress on console
on logMessage(logMessage)
	log "[" & (time string of (current date)) & "]: " & logMessage
end logMessage

-- true if iTunes is running. Otherwise false
on iTunesIsRunning()
	tell application "System Events"
		return (name of processes) contains "iTunes"
	end tell
end iTunesIsRunning

-- Get the amount of iTunes selected items
on iTunesSelectedItemsCount()
	tell application "iTunes"
		set selectionList to selection
		return count of selectionList
	end tell
end iTunesSelectedItemsCount

-- Return a list of iTunes selected items
on selectedItemsList()
	set itemsToMove to {}
	tell application "iTunes"
		repeat with currentItem in selection
			set filePath to location of currentItem
			tell application "Finder"
				set fileName to name of filePath
				copy fileName to the end of itemsToMove
			end tell
		end repeat
	end tell
	return itemsToMove
end selectedItemsList

-- Display the tutorial of how to use the script
on displayTutorial()
	set tutorial to "Como utilizar o script:" & return & return & "1. Abra o iTunes;" & return & "2. Selecione os arquivos que você deseja mover." & return & "3. Clique em 'Continuar'."
	display dialog tutorial buttons {"Continuar"} with title "Tutorial de execução do script" with icon 1
end displayTutorial

-- Show the dialog to select a directory
on selectNewPath()
	return POSIX path of (choose folder)
end selectNewPath

-- OSX use POSIX. So I need to convert the string path to POSIX path
on transformToPOSIXPath(thePath)
	return (POSIX path of thePath)
end transformToPOSIXPath

-- Move a specific file to the new path
on moveFile(oldPath, newPath)
	tell application "Finder"
		duplicate oldPath as POSIX file to newPath as POSIX file with replacing
	end tell
end moveFile

-- Change the location property on Itunes file and move the file to the new path
on changeFilesPath(newPath)
	logMessage("changing the file location...")
	
	set listCount to my iTunesSelectedItemsCount()
	set myCount to 0
	
	tell application "iTunes"
		set changedItems to {}
		repeat with currentItem in selection
			set myCount to myCount + 1
			
			set oldFilePath to (location of currentItem)
			
			tell application "Finder"
				set fileName to name of oldFilePath
				set newFilePath to newPath & fileName
			end tell
			
			my logMessage("current file (" & myCount & "/" & listCount & "): " & fileName)
			
			my moveFile(my transformToPOSIXPath(oldFilePath), my transformToPOSIXPath(newPath))
			
			set newLocation to location of currentItem
			set newLocation to (my transformToPOSIXPath(newFilePath) as POSIX file) as alias
			set location of currentItem to newLocation
		end repeat
		
		my logMessage("done.")
	end tell
	
end changeFilesPath


-- main script
if not iTunesIsRunning() then
	display dialog "O iTunes não está aberto" buttons {"OK"} with title "Erro ao executar o script" with icon 0
	return
end if

if iTunesSelectedItemsCount() is 0 then
	--display dialog "Nenhum item foi selecionado no iTunes" buttons {"OK"} with title "Execução interrompida" with icon 0
	return
end if

displayTutorial()

set newPath to selectNewPath()
set confirmMessagePrompt to "Novo path: " & newPath & return & return & "Os arquivos abaixo serão transferidos para o novo path:"

set itemsToMove to selectedItemsList()
set firstItem to item 1 of itemsToMove
set canContinue to choose from list itemsToMove cancel button name "Cancelar" with title "Itens que serão movidos" with prompt confirmMessagePrompt default items firstItem
if canContinue is false then
	display dialog "Operação cancelada pelo usuário." buttons {"OK"} with title "Fim da execução" with icon 1
	return
end if

changeFilesPath(newPath)
