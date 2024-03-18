while read p; do
  echo "source ~/.bashrc" > sub.sh
  echo "$p" >> sub.sh
  qsub -cwd -q bigmem sub.sh
  sleep 0.5
done < "$1"
