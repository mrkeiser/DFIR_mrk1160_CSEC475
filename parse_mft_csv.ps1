# Name: parse_mft_csv.ps1
# Desc: Powershell script to parse $MFT CSV dump
# Last Revision: 09/15/2017

# parameters
$CSV_file = 'c:\mftdump.csv' # variable for the dumped mft info csv file
$dataFile = 'c:\file.txt' # variable for the path of the file whose $DATA section is being listed

# Name: list_filestreams
# Desc: list file streams, file paths, file names, $SI timestamps, $FN timestamps
function list_filestreams{
	$CSV = Import-Csv -Path $CSV_file # import the CSV file
	foreach($entry in $CSV){ # get each entry in the filepath
		$Found = Get-ChildItem | % {Get-Item $_.FullName -stream *} | Select-Object -Property PSPath, Filename, Stream # prints a table of filepath, filename, and the file stream
		$Found | Get-Item | select-Object -Property Name, LastWriteTime # prints the filename and the time stamp
	}
}

# Name: dump_data
# Desc: Dump the $DATA section of a file, take filename as input, list file paths
function dump_data{
	$Data = Get-ChildItem -Path $dataFile | Get-Item $_.FullName -stream *} | Where Stream -ne ":$DATA" | Select-Object Stream, Filename # prints the Stream and filename of Streams with ":DATA" as the stream
}

# Name: id_timestomping
# Desc: identify potential timestomping entries
function id_timestomping{
	# if the timestamp for a file is different
	$Path = "c:\Users\$USER" # get a path for the c drive for current user
	Get-ChildItem -Path $Path -recurse -depth 1 |select-Object -Property Name, LastWriteTime # get file name and last write time
}
