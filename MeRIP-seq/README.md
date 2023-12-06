# A pipeline for RNA-seq and MeRIP-seq data analysis

For single-end sequencing, filenames of FASTQ files must always end with: ".fastq.gz".                           
For paired-end sequencing, the two FASTQ files of each sample are tagged by "R1" and "R2" respectively, so the filenames should always end with: ".R1.fastq.gz" or ".R2.fastq.gz". And other parts of them must be identical.                         

Put all your raw FASTQ fiels into one folder, such as folder name “1_rawFASTQ”.                  
You can run the scripts step by step or run one of them for a specific purpose.                 
Please run perl RASDA-N.pl -help to know it’s usage and what can the N-th script do.               


### xRNA-Seq_1.pl:                       
Check the quality of raw reads to identify possible experimental and sequencing errors or biases by using 4 tools: FastQC, fastp, FastQ_Screen, and MultiQC.           
Example: perl xRNA-Seq_1.pl -in 1_rawFASTQ                   
                        
xRNA-Seq_2.pl: Remove adapters and bases with low quality by using Trimmomatic and/or
trim_galore.
Example: perl xRNA-Seq_2.pl -in 1_rawFASTQ -out 2_removedAdapters
xRNA-Seq_3.pl: Remove PCR duplicates by using clumpify.sh of BBMap. (Optional)
You can run this script, if and only if barcodes were used to label duplicates, such as m6A-
SAC-Seq.
Example: perl xRNA-Seq_3.pl -in 2_removedAdapters -out 3_removedDups
xRNA-Seq_4.pl: Reverse-complement of R1 or R2 of paired-end reads. (Optional)
Usually, we do not need to run this script.
Example: perl xRNA-Seq_4.pl -in 3_removedDups -out 4_SE-RC
xRNA-Seq_5.pl: Quick determination of RNA-Seq strandedness by using
how_are_we_stranded_here. Please select one of the 3 examples:
Example: perl xRNA-Seq_5.pl -genome hg38 -in 2_removedAdapters
Example: perl xRNA-Seq_5.pl -genome hg38 -in 3_removedDups
Example: perl xRNA-Seq_5.pl -genome hg38 -in 4_SE-RC
Salmon and
-out 5_Strandedness/PE
-out 5_Strandedness/PE
-out 5_Strandedness/SE
xRNA-Seq_6.pl: Mapping reads to the reference genome by using Kallisto, Salmon, STAR,
or HISAT2. Information of strandness is required for Kaliisto and HISAT2, please see lines
625-625 and 764-766 of this script. Please select one of the 3 examples:
Example: perl xRNA-Seq_6.pl -genome hg38 -in 2_removedAdapters -out 6_rawBAM/PE -mis 0.05
Example: perl xRNA-Seq_6.pl -genome hg38 -in 3_removedDups
-out 6_rawBAM/PE -mis 0.05
Example: perl xRNA-Seq_6.pl -genome hg38 -in 4_SE-RC
-out 6_rawBAM/SE -mis 0.05
xRNA-Seq_7.pl: Only the mapped reads with MAPQ>20 are retained. And only reads on
chromosomes 1-22, X, and Y were ketp. Other reads are removed.
Example: perl xRNA-Seq_7.pl -genome hg38 -in 6_rawBAM/PE/3_STAR -out 7_finalBAM/PE/3_STAR
xRNA-Seq_8.pl: Convert BAM to Bigwig (BW).
Example: perl xRNA-Seq_8.pl
-in 7_finalBAM/PE/3_STAR -out 8_BW/PE/3_STAR
xRNA-Seq_9.pl: Cluster all samples to identiy outliers.
Example: perl xRNA-Seq_9.pl
-in 8_BW/PE/3_STAR -out 9_clstering/PE/3_STAR
xRNA-Seq_10.pl: Calculate raw counts by using featureCounts or htseq-count.
Example: perl xRNA-Seq_10.pl
-in 7_finalBAM/PE/3_STAR -out 10_rawCounts/PE/3_STAR
xRNA-Seq_11_DESeq2_CL.r : Identify differentially expressed genes by using DESeq2.
xRNA-Seq_11_edgeR_CL.r: Identify differentially expressed genes by using edgeR.
xRNA-Seq_12_bam_split.pl: clasify reads into two groups: plus strand and minus strand. This script will invoke
“xRNA-Seq_12_bam_split_paired_end.sh” or “”xRNA-Seq_12_bam_split_single_end.sh.
Example: perl xRNA-Seq_12_bam_split.pl -end paired -in 7_finalBAM/PE/3_STAR -out 12_splitBAM
Example: perl xRNA-Seq_12_bam_split.pl -end single -in 7_finalBAM/PE/3_STAR -out 12_splitBAM
xRNA-Seq_13_callPeaks_MeRIP.pl: call peaks by using MACS2.Example: perl xRNA-Seq_13_callPeaks_MeRIP.pl -genome hg38 -in 12_splitBAM/input-
Example: perl xRNA-Seq_13_callPeaks_MeRIP.pl -genome hg38 -in 12_splitBAM/input+
-ip 12_splitBAM/IP- -out 13_MACS2/minus
-ip 12_splitBAM/IP+ -out 13_MACS2/plus
