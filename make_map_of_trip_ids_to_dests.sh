psql -qtA marta -c "\copy (select trip_ids.trip_id, stop_name from stop_times join (select trip_id, max(stop_sequence) stop_sequence from trips join routes using (route_id) join stop_times using (trip_id) where route_short_name = '6' group by trip_id) trip_ids using(trip_id, stop_sequence) join stops using (stop_id)) to STDOUT with csv header;" | tail -n +2 | sed 's/,/":"/g' | sed 's/$/",/g' | sed 's/^/"/g' | sed -e '1s/^/{/' | sed -e '$s/",$/"}/'

# 5672702,INMAN PARK/REYNOLDSTOWN STATION - NORTH LOOP
# 5685245,INMAN PARK/REYNOLDSTOWN STATION - NORTH LOOP
# 5667250,INMAN PARK/REYNOLDSTOWN STATION - NORTH LOOP
# 5672703,LINDBERGH CENTER STATION - NORTH LOOP/MOROSGO DR
