tell application "System Events"
    tell process "Google Chrome"
        delay 2 
        repeat until (exists window "Сохранение как") or (exists window "Save As")
            delay 0.5
        end repeat
        if exists window "Сохранение как" then
            tell window "Сохранение как"
                keystroke "g" using {command down, shift down} -- Открыть выбор директории
                delay 1
                keystroke "/Users/asmodey/project/features/tmp/" -- Замени на свой путь
                delay 1
                keystroke return
                delay 1
                click button "Сохранить" of sheet 1
            end tell
        else if exists window "Save As" then
            tell window "Save As"
                keystroke "g" using {command down, shift down}
                delay 1
                keystroke "/Users/asmodey/Downloads/"
                delay 1
                keystroke return
                delay 1
                click button "Save"
            end tell
        end if
    end tell
end tell