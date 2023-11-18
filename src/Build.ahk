#Requires AutoHotkey >=2.0

; Set default encoding to UTF-8 (without BOM)
FileEncoding("UTF-8-RAW")
lineEnding := "`r`n" ; CRLF

; Only supports a normal #include with a file path (no Lib or IncludeAgain)
includeRegex := "im)^\s*#include\s+(.+?)\s*$"

; Run command: Build.ahk <entry file> <output file> <version number> [<docs url>]
arg_entryFile := A_Args[1]
arg_outputFile := A_Args[2]
arg_version := A_Args[3]

currentPath := A_WorkingDir
entryFileFullPath := currentPath . "\" . arg_entryFile
entryFileName := "", entryFileDir := ""
SplitPath(entryFileFullPath, &entryFileName, &entryFileDir)

if (!FileExist(entryFileFullPath)) {
    throw Error("Entry file not found: " . entryFileFullPath)
}


includedFiles := Map()
entryFileContent := FileRead(entryFileFullPath)
outputFileContent := ""

; Recursively include all files
loop {
    currentMatch := ""
    currentPos := RegExMatch(entryFileContent, includeRegex, &currentMatch, currentPos)
    if (currentPos == 0)
        break


}

SubstituteVariable(&outputFileContent, "buildVersion", arg_version)
SubstituteVariable(&outputFileContent, "buildTimestamp", A_NowUTC)

SanitizeScript(content) {
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
