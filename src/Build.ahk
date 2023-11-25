#Requires AutoHotkey >=2.0

; Set default encoding to UTF-8 (without BOM)
FileEncoding("UTF-8-RAW")
lineEnding := "`r`n" ; CRLF
SetWorkingDir(A_InitialWorkingDir)

; Only supports a normal #include with a file path (no Lib or IncludeAgain)
includeRegex := "im)^( *)#include\s+(.+?) *$"
requiresRegex := "im)^( *)#requires.*"
extraLinesRegex := "im)\r?\n\r?\n(\r?\n)*"

; Run command: Build.ahk <entry file> <output file> <version number>
arg_entryFile := A_Args.Has(1) ? A_Args[1] : "VMR.ahk"
arg_outputFile := A_Args.Has(2) ? A_Args[2] : "..\dist\VMR.ahk"
arg_version := A_Args.Has(3) ? A_Args[3] : "1.0.0"

; Check if we should use the version from ahkpm.json
if (arg_version = "ahkpm") {
    ahkpmJson := FileRead("./ahkpm.json")
    RegExMatch(ahkpmJson, 'i)"version": "(.+?)"', &versionMatch)
    arg_version := versionMatch[1]
}

currentPath := A_WorkingDir
entryFileFullPath := currentPath "\" arg_entryFile
SplitPath(entryFileFullPath, &entryFileName, &entryFileDir)
SplitPath(arg_outputFile, &outputFileName, &outputFileDir)

outputContent := FileRead(entryFileFullPath)
includedFiles := Map()

; Recursively include all files
currentPos := 1
loop {
    currentPos := RegExMatch(outputContent, includeRegex, &currentMatch, currentPos)
    if (currentPos == 0)
        break

    includePrefix := currentMatch[1]
    includePath := currentMatch[2]

    SplitPath(includePath, &fileName, &fileDir)
    replacement := ""

    ; Check if the file has already been included
    if (!includedFiles.Has(fileName)) {
        includedFiles.Set(fileName, true)
        fileDir := fileDir ? fileDir : "."
        replacement := ProcessScript(FileRead(entryFileDir "\" fileDir "\" fileName), includePrefix)
    }

    outputContent := RegExReplace(outputContent, "\Q" currentMatch[0] "\E\n{0,1}", replacement)
}

; Remove extra lines
outputContent := RegExReplace(outputContent, extraLinesRegex, lineEnding)

; Replace placeholder variables
SubstituteVariable(&outputContent, "buildVersion", arg_version)
SubstituteVariable(&outputContent, "buildTimestamp", FormatTime(A_NowUTC, "yyyy-MM-dd HH:mm:ss UTC"))

; ensure the output directory exists
if (outputFileDir && !DirExist(outputFileDir))
    DirCreate(outputFileDir)

; Write the output file
FileOpen(arg_outputFile, "w").Write(outputContent)

ProcessScript(content, prefix) {
    content := RegExReplace(content, requiresRegex, "")
    content := Trim(content, " `t`r`n") "`n"
    content := InsertPrefix(content, prefix)
    return content
}

InsertPrefix(text, prefix) {
    output := ""
    loop parse text, "`n", "`r" {
        output .= prefix A_LoopField lineEnding
    }
    return output
}

SubstituteVariable(&text, variableName, value) {
    static varRegexTemplate := "i)<{}>"
    text := RegExReplace(text, Format(varRegexTemplate, variableName), value)
}
