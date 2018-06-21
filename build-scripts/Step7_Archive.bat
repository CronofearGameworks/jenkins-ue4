set "str=%~1"
cd C:\_ProjectNil\_JenkinsCICD\Builds
"C:\Program Files\7-Zip\7z.exe" a Project_Nil_%str%.zip C:\ProjectName\_JenkinsCICD\Builds\WindowsNoEditor\*