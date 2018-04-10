###########Step1 handle######################################################################
for i in $(ls *); do usearch -fastx_uniques $i -relabel $i. -fastaout $i.fasta -sizeout; done
cat *.fasta.fasta>reads.fasta
usearch -fastx_uniques reads.fasta -sizeout -sizein -fastaout uniques.fasta
usearch -unoise3 uniques.fasta -zotus zotus.fasta
awk 'BEGIN {n=1}; />/ {print ">OTU_" n; n++} !/>/ {print}' ./zotus.fasta > ./zrep_seqs.fasta
biom convert -i zotutab.txt -o zotutable.biom --table-type="OTU table" --to-json
###########Step2 Taxonomy####################################################################
nohup assign_taxonomy.py -i zrep_seqs.fasta -m rdp -r ~/database/99_otus.fasta -t ~/database/99_otus.txt -o ztax --rdp_max_memory=500000 &
