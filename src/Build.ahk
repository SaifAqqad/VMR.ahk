#Requires AutoHotkey >=2.0

; Set default encoding to UTF-8 (without BOM)
FileEncoding("UTF-8-RAW")
lineEnding := "`r`n" ; CRLF
SetWorkingDir(A_InitialWorkingDir)

; Only supports a normal #include with a file path (no Lib or IncludeAgain)
includeRegex := "im)^\s*#include\s+(.+?)\s*$"

; Run command: Build.ahk <entry file> <output file> <version number>
arg_entryFile := A_Args[1]
arg_outputFile := A_Args[2]
arg_version := A_Args[3]

; Check if we should use the version from ahkpm.json
if (arg_version = "ahkpm") {
    ahkpmJson := FileRead("./ahkpm.json")
    RegExMatch(ahkpmJson, 'i)"version": "(.+?)"', &versionMatch)
    arg_version := versionMatch[1]
}

currentPath := A_WorkingDir
entryFileFullPath := currentPath . "\" . arg_entryFile
SplitPath(entryFileFullPath, &entryFileName, &entryFileDir)

outputContent := FileRead(entryFileFullPath)
includedFiles := Map()

; Recursively include all files
currentPos := 0
loop {
    currentPos := RegExMatch(outputContent, includeRegex, &currentMatch, currentPos)
    if (currentPos == 0)
        break

    SplitPath(currentMatch[1], &fileName, &fileDir)
    ; Check if the file has already been included
    if (includedFiles.Has(fileName)) {
        outputContent := RegExReplace(outputContent, "\Q" currentMatch[0] "\E\n", "")
    }
    else {

    }


}

SubstituteVariable(&outputContent, "buildVersion", arg_version)
SubstituteVariable(&outputContent, "buildTimestamp", A_NowUTC)

ProcessScript(content) {
    return Trim(content, " `t`r`n")
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
