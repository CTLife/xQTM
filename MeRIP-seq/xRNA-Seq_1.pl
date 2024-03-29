#!/usr/bin/env  perl
use  strict;
use  warnings;
use  v5.12;    ## Perl version must be >= 5.12
###################################################################################################################################################################################################





###################################################################################################################################################################################################
my $input_g  = '';  ## such as "1_rawFASTQ", global variable.   
{
## Help Infromation
my $HELP = '
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        Step 1: This script will directly assess the quality of raw reads to identify possible experimental and sequencing errors or biases by using 4 tools: FastQC, fastp, FastQ_Screen, and MultiQC.
                FASTQ files must be compressed. Now, acceptable compression format is gzip (files ending with a .gz ).

                For single-end sequencing, filenames of FASTQ files must always end with: ".fastq.gz".  
                For paired-end sequencing, the two FASTQ files of each sample are tagged by "R1" and "R2" respectively, so the filenames should always end with:
                ".R1.fastq.gz"  or ".R2.fastq.gz". And other parts of them must be identical. 

                If this script works well, you do not need to check the the versions of the tools or packages which were used in this script. 
                And you do not need to exactly match the versions of the softwares or packages.
                If some errors or warnings are reported, please check the versions of the tools or packages.

                The versions of tools and packages are used in this script (They are showed for reference only. And you do not need to match the versions exactly.):  
                        Perl,   5.34.0   (perl    -v)
                        FastQC, v0.11.9  (fastqc  -v)
                        fastp,  0.23.2   (fastp   -v)
                        FastQ_Screen,  0.15.1  (fastq_screen -v)
                        MultiQC,       1.14    (multiqc --version)
                        gunzip,        1.10    (gunzip  --version)
                       
        Usage:
               perl  xRNA-Seq_1.pl    [-version]    [-help]     [-in inputDir]   
        For instance:
               nohup   time    perl  xRNA-Seq_1.pl    -in 1_rawFASTQ   > xRNA-Seq_1.runLog.txt  2>&1    & 

        ----------------------------------------------------------------------------------------------------------
        Optional arguments:
        -version        Show version number of this program and exit.

        -help           Show this help message and exit.

        Required arguments:
        -in inputDir        "inputDir" is the name of input path that contains your FASTQ files.  (no default)
                            This script will also write outputs into inputDir.
        -----------------------------------------------------------------------------------------------------------

        For more details about this pipeline and other NGS data analysis piplines, please visit https://github.com/CTLife/Sequencing_DNA_RNA_Protein
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------
';

## Version Infromation
my $version = "    The 1st Step, version 1.2,  2023-07-25.";

## Keys and Values
if ($#ARGV   == -1)   { say  "\n$HELP\n";  exit 0;  }       ## when there are no any command argumants.
if ($#ARGV%2 ==  0)   { @ARGV = (@ARGV, "-help") ;  }       ## when the number of command argumants is odd.
my %args = @ARGV;

## Initialize  Variables
$input_g  = '1_rawFASTQ';     ## This is only an initialization value or suggesting value, not default value.

## Available Arguments 
my $available = "   -version    -help    -in  ";
my $boole = 0;
while( my ($key, $value) = each %args ) {
    if ( ($key =~ m/^\-/) and ($available !~ m/\s$key\s/) ) {say    "\n\tCann't recognize $key";  $boole = 1; }
}
if($boole == 1) {
    say  "\tThe Command Line Arguments are wrong!";
    say  "\tPlease see help message by using 'perl  xRNA-Seq_1.pl  -help' \n";
    exit 0;
}

## Get Arguments 
if ( exists $args{'-version' }   )     { say  "\n$version\n";    exit 0; }
if ( exists $args{'-help'    }   )     { say  "\n$HELP\n";       exit 0; }
if ( exists $args{'-in'      }   )     { $input_g  = $args{'-in'      }; }else{say   "\n -in  is required.\n";   say  "\n$HELP\n";    exit 0; }

## Conditions
$input_g  =~ m/^\S+$/    ||  die   "\n\n$HELP\n\n";

## Print Command Arguments to Standard Output
say  "\n
        ################ Arguments ###############################
                Input   Path:  $input_g
        ##########################################################
\n";
}
###################################################################################################################################################################################################





###################################################################################################################################################################################################
say   "\n\n\n\n\n\n##################################################################################################";
say   "Running ......";
sub myMakeDir  {
    my $path = $_[0];
    if ( !( -e $path) )  { system("mkdir  -p  $path"); }
    if ( !( -e $path) )  { mkdir $path  ||  die;       }
}
my $input2_g = "$input_g/QC_Results";
&myMakeDir($input2_g);

opendir(my $DH_input_g, $input_g)  ||  die;
my @inputFiles_g = readdir($DH_input_g);
@inputFiles_g    = sort(@inputFiles_g);
my $numCores_g   = 8;
###################################################################################################################################################################################################





###################################################################################################################################################################################################
{
## These commands must be available:
say   "\n\n\n\n\n\n##################################################################################################";
say   "The versions of tools ......";
sub printVersion  {
    my $software = $_[0];
    system("echo    '##############################################################################'  >> $input2_g/VersionsOfSoftwares.txt   2>&1");
    system("echo    '#########$software : '                                                           >> $input2_g/VersionsOfSoftwares.txt   2>&1");
    system("$software                                                                                 >> $input2_g/VersionsOfSoftwares.txt   2>&1");
    system("echo    '\n\n\n\n\n\n'                                                                    >> $input2_g/VersionsOfSoftwares.txt   2>&1");
}
&printVersion(" perl             --version ");
&printVersion(" fastqc           --version ");
&printVersion(" fastp            --version ");
&printVersion(" fastq_screen     --version ");
&printVersion(" multiqc          --version ");
&printVersion(" gunzip           --version ");
&printVersion(" gzip             --version ");
}
###################################################################################################################################################################################################

 



###################################################################################################################################################################################################
say   "\n\n\n\n\n\n##################################################################################################";
say   "Detecting single-end and paired-end FASTQ files ......";
my @singleEnd_g   = ();
my @pairedEnd_g   = ();
open(seqFiles_FH_g, ">", "$input2_g/singleEnd-pairedEnd-Files.txt")  or  die;

for ( my $i=0; $i<=$#inputFiles_g; $i++ ) {
    next unless $inputFiles_g[$i] !~ m/^[.]/;
    next unless $inputFiles_g[$i] !~ m/[~]$/;
    next unless $inputFiles_g[$i] !~ m/\.sh$/;
    next unless $inputFiles_g[$i] !~ m/^unpaired/;
    next unless $inputFiles_g[$i] !~ m/^QC_Results$/;
    next unless $inputFiles_g[$i] !~ m/\.txt/;
    next unless $inputFiles_g[$i] =~ m/\.fastq.gz$/;

    my $temp =  $inputFiles_g[$i]; 
    say    "\t......$temp";
    if ($temp !~ m/^(\S+)\.R[12]\.fastq.gz$/) {   ## sinlge end sequencing files.
        $temp =~ m/^(\S+)\.fastq.gz$/   or  die;
        $singleEnd_g[$#singleEnd_g+1] =  $temp;
        say         "\t\t\t\tSingle-end sequencing files: $temp\n";
        say  seqFiles_FH_g  "Single-end sequencing files: $temp\n";
    }else{     ## paired end sequencing files.
        $temp =~ m/^(\S+)\.R[12]\.fastq.gz$/  or  die;
        $pairedEnd_g[$#pairedEnd_g+1] =  $temp;
        say        "\t\t\t\tPaired-end sequencing files: $temp\n";
        say seqFiles_FH_g  "Paired-end sequencing files: $temp\n";
    }
}

@singleEnd_g  = sort(@singleEnd_g);
@pairedEnd_g  = sort(@pairedEnd_g);

( ($#pairedEnd_g+1)%2 == 0 )  or die;
say   seqFiles_FH_g  "\n\n\n\n\n";
say   seqFiles_FH_g  "All single-end sequencing files:@singleEnd_g\n\n\n";
say   seqFiles_FH_g  "All paired-end sequencing files:@pairedEnd_g\n\n\n";
say          "\t\t\t\tAll single-end sequencing files:@singleEnd_g\n\n";
say          "\t\t\t\tAll paired-end sequencing files:@pairedEnd_g\n\n";

my $numSingle_g = $#singleEnd_g + 1;
my $numPaired_g = $#pairedEnd_g + 1;

say seqFiles_FH_g   "\nThere are $numSingle_g single-end sequencing files.\n";
say seqFiles_FH_g   "\nThere are $numPaired_g paired-end sequencing files.\n";
say           "\t\t\t\tThere are $numSingle_g single-end sequencing files.\n";
say           "\t\t\t\tThere are $numPaired_g paired-end sequencing files.\n";


for ( my $i=0; $i<$#pairedEnd_g; $i=$i+2 ) {
    my $temp = $pairedEnd_g[$i]; 
    $temp =~ s/\.R1\.fastq/.R2.fastq/  or die "\n##Error-1: $temp ##\n\n";
    ($pairedEnd_g[$i+1] eq $temp) or die "\n##Error-2: $temp ## $pairedEnd_g[$i+1] ##\n\n";
}

print("\n\n\n\n\n#########################################\n");
###################################################################################################################################################################################################





###################################################################################################################################################################################################
sub  myQC_FASTQ_1  {
    my $dir1      =  $_[0];   ## All the fastq files must be in this folder.
    my $QCresults = "$dir1/QC_Results";
    my $FastQC    = "$QCresults/1_FastQC";
    my $fastp     = "$QCresults/2_fastp";
    my $MultiQC1  = "$QCresults/MultiQC/1_FastQC";
    my $MultiQC2  = "$QCresults/MultiQC/2_fastp";
    &myMakeDir($QCresults);
    &myMakeDir($FastQC);
    &myMakeDir($fastp);
    &myMakeDir($MultiQC1);
    &myMakeDir($MultiQC2);  
    opendir(my $FH_Files, $dir1) || die;       
    my @Files = readdir($FH_Files);
    say   "\n\n\n\n\n\n##################################################################################################";
    say   "Detecting the quality of all FASTQ files by using FastQC, fastp and MultiQC ......";
    for ( my $i=0; $i<=$#Files; $i++ ) {
        next unless $Files[$i] =~ m/\.fastq.gz$/;
        next unless $Files[$i] !~ m/^[.]/;
        next unless $Files[$i] !~ m/[~]$/;
        next unless $Files[$i] !~ m/\.sh$/;
        next unless $Files[$i] !~ m/^unpaired/;
        next unless $Files[$i] !~ m/^QC_Results$/;
        next unless $Files[$i] !~ m/\.txt/;
        my $temp = $Files[$i];
        say    "\t......$temp";
        $temp =~ s/\.fastq\.\S+$//   ;
        $temp =~ s/\.fastq$//    ;
        system( "fastqc    --outdir $FastQC   --threads $numCores_g   --format fastq   --kmers 7    $dir1/$Files[$i]    >>  $FastQC/$temp.runLog.txt     2>&1" );
        system( "fastp    --in1 $dir1/$Files[$i]  -p  --report_title $temp  --thread $numCores_g     --json $fastp/$temp.fastp.json   --html $fastp/$temp.fastp.html   --report_title $temp  --reads_to_process 1000000  >> $fastp/$temp.runLog.txt   2>&1" );                                           
    }
    system( "multiqc  --title FastQC   --filename  FastQC  --module  fastqc  --verbose  --export  --outdir $MultiQC1   --pdf  --profile-runtime   $FastQC  >> $MultiQC1/MultiQC.FastQC.runLog.txt   2>&1" );
    system( "multiqc  --title fastp    --filename  fastp   --module  fastp   --verbose  --export  --outdir $MultiQC2   --pdf  --profile-runtime   $fastp   >> $MultiQC2/MultiQC.fastp.runLog.txt    2>&1" );
}
###################################################################################################################################################################################################





###################################################################################################################################################################################################
sub  myQC_FASTQ_2  {
    my $dir1      =  $_[0];   ## All the fastq files must be in this folder.
    my $QCresults = "$dir1/QC_Results";
    my $FastQ_Screen   = "$QCresults/3_FastQ-Screen";
    my $MultiQC        = "$QCresults/MultiQC/3_FastQ-Screen";
    &myMakeDir($QCresults);
    &myMakeDir($FastQ_Screen);
    &myMakeDir($MultiQC);
    opendir(my $FH_Files, $dir1) || die;     
    my @Files = readdir($FH_Files);
    say   "\n\n\n\n\n\n##################################################################################################";
    say   "Detecting the quality of all FASTQ files by using FastQ_Screen and MultiQC ......";
    for ( my $i=0; $i<=$#Files; $i++ ) {
        next unless $Files[$i] =~ m/\.fastq.gz$/;
        next unless $Files[$i] !~ m/^[.]/;
        next unless $Files[$i] !~ m/[~]$/;
        next unless $Files[$i] !~ m/\.sh$/;
        next unless $Files[$i] !~ m/^unpaired/;
        next unless $Files[$i] !~ m/^QC_Results$/;
        next unless $Files[$i] !~ m/\.txt/;
        my $temp = $Files[$i];
        say    "\t......$temp";
        $temp =~ s/\.fastq\.\S+$//    ;
        $temp =~ s/\.fastq$//    ;
        system( "fastq_screen  --aligner  bowtie2  --outdir $FastQ_Screen/$temp  --threads $numCores_g    --subset 800000   $dir1/$Files[$i]      >> $FastQ_Screen/$temp.runLog.txt      2>&1" );
    }
    system( "multiqc  --title FastQ_Screen  --filename  FastQ_Screen  --module  fastq_screen   --verbose  --export  --outdir $MultiQC   --pdf  --profile-runtime       $FastQ_Screen     >> $MultiQC/MultiQC.FastQ-Screen.runLog.txt   2>&1" );
}
###################################################################################################################################################################################################





###################################################################################################################################################################################################
&myQC_FASTQ_1($input_g);
&myQC_FASTQ_2($input_g);
###################################################################################################################################################################################################





###################################################################################################################################################################################################
say   "\n\n\n\n\n\n##################################################################################################";
say   "\tJob Done! Cheers! \n\n\n\n\n";





## END





