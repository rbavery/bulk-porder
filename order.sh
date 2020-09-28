# export pl api key if porder doesn't work after using planet init
export PL_API_KEY=######################
# create an idlist from an aoi and date range. there are other filters in the porder docs for more complicated orders
porder idlist --input "/home/rave/kelsey_order/data/AOI_PunjabBurning_poly_simple.geojson" --start "2019-08-26" --end "2019-12-20" --item "PSScene4Band" --asset "analytic_sr" --outfile "/home/rave/kelsey_order/data/idlist.csv" --cmax ".50" --overlap "10" --number 10000000
# splits idlist into multiple csvs with max order size length. you can make 10 orders of size 500 at a time for a total of 5000 assets being processed at a time
porder idsplit --idlist "/home/rave/tana-spin/waves/kelsey_order/data/idlist.csv" --lines "500" --local "/home/rave/tana-spin/waves/kelsey_order/data/splitcsvs"
# get list of csv filenames
csvs=$(ls /home/rave/tana-spin/waves/kelsey_order/data/splitcsvs/*.csv)
# used to pause if too many orders running using while loop
running=$(porder ostate --state running --start 2020-09-25 --end 2020-09-26 | sed -n 5,14p | awk -F "|" '{print $4}' | wc -l)
# this will only work if there's a max of 10 csvs in the splitcsv folder. otherwise too many concurrent requests
for csv in $csvs; while [ $running -gt 10 ]; do echo "can't order"; sleep 100; running=$(porder ostate --state running --start 2020-09-25 --end 2020-09-26 | sed -n 5,14p | awk -F "|" '{print $4}' | wc -l); done; do porder order --name "kuiseb {$csv}" --idlist "/home/rave/serdp/kuiseb/bulk-porder/splitcsvs-kuiseb/$csv" --item "PSScene4Band" --boundary "/home/rave/serdp/kuiseb/bulk-porder/data/kuiseb.geojson" --bundle "analytic_sr_udm2,analytic_sr" --op clip harmonize email;   done
# get space delimited order links
orders=$(porder ostate --state success --start 2020-09-16 --end 2020-09-18 | sed -n 5,14p | awk -F "|" '{print $4}')
# download each order using the async/multiprocessing downloader, each order link is processed sequentially
for link in $orders; do porder multiproc --url $link --local "/home/rave/tana-spin/waves/kelsey_order/download"; done  
