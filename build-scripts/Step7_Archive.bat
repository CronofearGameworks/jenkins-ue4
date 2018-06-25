set "str=%~1"
cd C:\ProjectName\_JenkinsCICD\Builds
"C:\Program Files\7-Zip\7z.exe" a ProjectName%str%.zip C:\ProjectName\_JenkinsCICD\Builds\WindowsNoEditor\*
