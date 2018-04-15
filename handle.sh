###########Step1 handle######################################################################
for i in $(ls *); do usearch -fastx_uniques $i -relabel $i. -fastaout $i.fasta -sizeout; done
cat *.fasta.fasta>reads.fasta
usearch -fastx_uniques reads.fasta -sizeout -sizein -fastaout uniques.fasta
usearch -unoise3 uniques.fasta -zotus zotus.fasta
awk 'BEGIN {n=1}; />/ {print ">OTU_" n; n++} !/>/ {print}' ./zotus.fasta > ./zrep_seqs.fasta
biom convert -i zotutab.txt -o zotutable.biom --table-type="OTU table" --to-json
###########Step2 Taxonomy####################################################################
nohup assign_taxonomy.py -i zrep_seqs.fasta -m rdp -r ~/database/99_otus.fasta -t ~/database/99_otus.txt -o ztax --rdp_max_memory=500000 &
biom add-metadata -i zotutab.txt --observation-metadata-fp ztax/zrep_seqs_tax_assignments.txt -o ztable_tax.biom --sc-separated taxonomy --observation-header OTUID,taxonomy
biom summarize-table -i ztable_tax.biom
######################################################Step3 Local running####################################################################
core_diversity_analyses.py -i ztable_tax.biom -o 3.diversity -m mapping.txt -e 70882 -p diversitypar.txt --nonphylogenetic_diversity
gunzip 3.diversity/table_even70882.biom.gz
biom convert -i 3.diversity/table_even70882.biom -o zotu_table_even70882.txt --to-tsv --header-key taxonomy --table-type="OTU table"
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!copy issues
######################################################Step4 Sever Running phylogeny analysis####################################################################
filter_fasta.py -f zrep_seqs.fasta -b table_even70882.biom -o filter_even_table.fasta
nohup align_seqs.py -i filter_even_table.fasta -m muscle -o aligned_seqs.fasta &
filter_alignment.py -i aligned_seqs.fasta -o trimed_align_seqs.fasta
make_phylogeny.py -i trimed_align_seqs.fasta -o zrep_set.tre





echo 'PATH=$PATH: /home1/lirenhui/software/standard-RAxML-master/' >> ~/.bashrc
source ~/.bashrc