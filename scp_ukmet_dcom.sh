# - copy this file to /lfs/h1/nco/stmp/ying.lin/
#   when necessary change GAB12 to GAB00, edit out file(s) already exist on dcom
# - sudo -iu dfprod; cd  /lfs/h1/ops/prod/dcom/$today/wgrbbul/ukmet_hires
# - /lfs/h1/nco/stmp/ying.lin/scp_ukmet_dcom.sh  
for file in \
GAB1211T.GRB \
GAB1222T.GRB \
GAB12AAT.GRB \
GAB12BBT.GRB \
GAB12CCT.GRB \
GAB12DDT.GRB \
GAB12EET.GRB \
GAB12FFT.GRB \
GAB12GGT.GRB \
GAB12HHT.GRB \
GAB12IIT.GRB \
GAB12JJT.GRB \
GAB12KKT.GRB \
GAB12LLT.GRB \
GAB12MMT.GRB \
GAB12NNT.GRB \
GAB12OOT.GRB \
GAB12PPA.GRB \
GAB12QQT.GRB \
GAB12TTT.GRB \
GAB12UUT.GRB \
GAB12VVT.GRB
do
  scp dbnet@ncorzdm:/home/ftp/data/nco/ukmet_hires/$file .
done


