;reads all data but i can save them to .sav file now

PRO alldata,data,efx,efz,wpa,wpc,wpst

readgeantdata,data

readdataset,efx,efz,wpa,wpc,wpst,dirwpa='NewMesh/', dirste='NewMesh/', dircat='NewMesh/'

END
