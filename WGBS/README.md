# A pipeline for RNA-seq and MeRIP-seq data analysis

For single-end sequencing, filenames of FASTQ files must always end with: ".fastq.gz".                           
For paired-end sequencing, the two FASTQ files of each sample are tagged by "R1" and "R2" respectively, so the filenames should always end with: ".R1.fastq.gz" or ".R2.fastq.gz". And other parts of them must be identical.                         

Put all your raw FASTQ fiels into one folder, such as folder name “1_rawFASTQ”.                  
You can run the scripts step by step or run one of them for a specific purpose.                 
Please run perl BS-Seq_N.pl -help to know it’s usage and what can the N-th script do.               



### BS-Seq_1.pl: Check the quality of raw reads to identify possible experimental and sequencing errors or biases by using 4 tools: FastQC, fastp, FastQ_Screen, and MultiQC.       
### BS-Seq_2.pl: Remove adapters and bases with low quality by using Trimmomatic.   
### BS-Seq_3.pl: Remove PCR duplicates with 100% identity by using clumpify.sh of BBMap. (Optional)          
