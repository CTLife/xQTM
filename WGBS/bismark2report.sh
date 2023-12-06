out="bismark2report"
mkdir $out
bismark2report   --dir  $out    --alignment_report  *_PE_report.txt   --splitting_report  $out/split_report.txt       --mbias_report  $out/M-bias.txt    
