; Run command: autohotkey.exe .\Build.ahk <version number>
global new_line:= "`r`n"
, header := "
(LTrim Join`r`n
    ;
    ; VMR.ahk v" A_Args[1] "
    ; Build timestamp: " A_NowUTC "
    ; Repo: https://github.com/SaifAqqad/VMR.ahk
    ; Docs: https://saifaqqad.github.io/VMR.ahk
    ;
)"
, output_path:= A_ScriptDir "\dist"
, src_path:= A_ScriptDir "\src"
, base_file := "VMR.ahk"
, file_content:= FileOpen(src_path "\" base_file, "r").Read()

global include_regex:= "imO)^( *){{\s*include\s+\""(.+)\""\s*}}$"
, current_match:=""
, current_pos:=1

Loop{
    current_pos:= RegExMatch(file_content, include_regex, current_match, current_pos)
    if(current_pos = 0)
        break
    str_to_replace:= current_match.Value()
    indent_value:= current_match.Value(1)
    include_path:= src_path "\" current_match.Value(2)
    include_file_content:= FileOpen(include_path, "r").Read()
    if(indent_value)
        include_file_content:= insertPrefix(include_file_content, indent_value)
    include_file_length:= StrLen(include_file_content)
    if(include_file_length){
        file_content:= RegExReplace(file_content, "\Q" str_to_replace "\E", include_file_content,, 1, current_pos)
        current_pos+= include_file_length
    }  
}

global header_regex:= "imO)^( *){{\s*header\s*}}$"
file_content:= RegExReplace(file_content, header_regex, header,,1)

FileCreateDir, % output_path
FileOpen(output_path "\" base_file, "w").Write(file_content)


insertPrefix(text, prefix){
    output:=""
    Loop, parse, text, `n, `r
    {
        output.= prefix A_LoopField new_line
    }
    return output
}