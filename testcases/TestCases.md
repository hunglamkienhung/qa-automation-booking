# Hotel booking — test cases

1000 cases across a self-written mini-stay service (a real SQLite store behind the search, hold, booking lifecycle and cancellation flows) and the live Frankfurter FX API. Generated from `../features/*.feature` by `build.js`; do not edit by hand.

## mini-stay-db (252)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 1 | BE/DB | High | The store has the documented tables |
| 2 | BE/DB | High | A room's capacity and inventory are bounded by CHECK |
| 3 | BE/DB | High | A room type references a real hotel |
| 4 | BE/DB | High | A booking references a real guest, hotel and room type |
| 5 | BE/DB | High | A booking event references a real booking |
| 6 | BE/DB | High | Money amounts are bounded by CHECK |
| 7 | BE/DB | High | A booking's dates run forward and cover at least one night |
| 8 | BE/DB | High | A booking status is one of the lifecycle states |
| 9 | BE/DB | Medium | A booking event names a known actor |
| 10 | BE/DB | Medium | A cancellation policy is one of the known kinds |
| 11 | BE/DB | Medium | A ledger entry is a real, non-zero amount with a known reason and party |
| 12 | BE/DB | Medium | A hotel's tax rate is not negative |
| 13 | BE/DB | Medium | An idempotency key is unique across bookings |
| 14 | BE/DB | Medium | Seeding twice leaves the same rows |
| 15 | BE/DB | High | Holding a room writes a held booking with the priced money |
| 16 | BE/DB | High | A held booking snapshots the rate and the cancellation policy |
| 17 | BE/DB | High | The hold expiry is the creation time plus the hold window |
| 18 | BE/DB | High | Confirming a hold moves it to confirmed and records the transition |
| 19 | BE/DB | High | Confirming posts the price to the ledger |
| 20 | BE/DB | Medium | A held booking has posted nothing to the ledger |
| 21 | BE/DB | High | A full stay writes an event for every transition |
| 22 | BE/DB | High | Cancelling a confirmed booking records the transition and a refund |
| 23 | BE/DB | Medium | Cancelling an unpaid hold refunds nothing |
| 24 | BE/DB | Medium | A no-show is a hotelier transition off a confirmed booking |
| 25 | BE/DB | High | Confirming an expired hold marks it expired and pays nothing |
| 26 | BE/DB | High | A held booking occupies one room on each of its nights |
| 27 | BE/DB | High | The scarce room is never occupied beyond its inventory |
| 28 | BE/DB | Medium | A cancelled hold stops occupying the room |
| 29 | BE/DB | Medium | No booking references a missing guest, hotel or room type |
| 30 | BE/DB | Medium | Every confirmed or cancelled booking's ledger matches its state |
| 31 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 32 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 33 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 34 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 35 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 36 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 37 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 38 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 39 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 40 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 217 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 218 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 219 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 220 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 221 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 222 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 223 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 224 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 225 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 226 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 227 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 228 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 801 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 802 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 803 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 804 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 805 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 806 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 807 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 808 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 809 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 810 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 811 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 812 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 813 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 814 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 815 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 816 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 817 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 818 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 819 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 820 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 821 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 822 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 823 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 824 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 825 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 826 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 827 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 828 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 829 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 830 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 831 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 832 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 833 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 834 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 835 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 836 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 837 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 838 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 839 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 840 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 841 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 842 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 843 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 844 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 845 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 846 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 847 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 848 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 849 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 850 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 851 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 852 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 853 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 854 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 855 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 856 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 857 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 858 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 859 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 860 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 861 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 862 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 863 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 864 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 865 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 866 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 867 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 868 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 869 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 870 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 871 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 872 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 873 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 874 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 875 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 876 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 877 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 878 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 879 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 880 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 881 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 882 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 883 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 884 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 885 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 886 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 887 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 888 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 889 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 890 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 891 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 892 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 893 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 894 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 895 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 896 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 897 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 898 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 899 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 900 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 901 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 902 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 903 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 904 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 905 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 906 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 907 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 908 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 909 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 910 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 911 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 912 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 913 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 914 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 915 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 916 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 917 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 918 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 919 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 920 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 921 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 922 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 923 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 924 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 925 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 926 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 927 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 928 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 929 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 930 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 931 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 932 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 933 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 934 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 935 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 936 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 937 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 938 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 939 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 940 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 941 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 942 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 943 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 944 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 945 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 946 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 947 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 948 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 949 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 950 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 951 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 952 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 953 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 954 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 955 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 956 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 957 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 958 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 959 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 960 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 961 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 962 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 963 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 964 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 965 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 966 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 967 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 968 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 969 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 970 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 971 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 972 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 973 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 974 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 975 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 976 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 977 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 978 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 979 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 980 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 981 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 982 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 983 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 984 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 985 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 986 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 987 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 988 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 989 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 990 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 991 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 992 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 993 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 994 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 995 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 996 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 997 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 998 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 999 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 1000 | BE/DB | Medium | A <label> hold prices and occupies correctly |

## mini-stay-pricing (204)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 41 | BE/API | High | A two-night standard double is priced to the cent |
| 42 | BE/API | High | A three-night standard double |
| 43 | BE/API | High | A two-night sea-view suite |
| 44 | BE/API | High | A one-night penthouse |
| 45 | BE/API | High | A two-night queen room at the other hotel's tax rate |
| 46 | BE/API | High | A three-night family cabin |
| 47 | BE/API | Medium | A quote is internally consistent |
| 48 | BE/API | Medium | A quote carries the room's cancellation policy |
| 49 | BE/API | Medium | A quote reports the number of nights it priced |
| 50 | BE/API | Medium | <label> prices to the reference formula |
| 51 | BE/API | Medium | <label> prices to the reference formula |
| 52 | BE/API | Medium | <label> prices to the reference formula |
| 53 | BE/API | Medium | <label> prices to the reference formula |
| 54 | BE/API | Medium | <label> prices to the reference formula |
| 55 | BE/API | Medium | <label> prices to the reference formula |
| 56 | BE/API | Medium | <label> prices to the reference formula |
| 57 | BE/API | Medium | <label> prices to the reference formula |
| 58 | BE/API | Medium | <label> prices to the reference formula |
| 59 | BE/API | Medium | <label> prices to the reference formula |
| 60 | BE/API | Medium | <label> prices to the reference formula |
| 61 | BE/API | Medium | <label> prices to the reference formula |
| 62 | BE/API | Medium | <label> prices to the reference formula |
| 63 | BE/API | Medium | <label> prices to the reference formula |
| 64 | BE/API | Medium | <label> prices to the reference formula |
| 65 | BE/API | Medium | <label> prices to the reference formula |
| 66 | BE/API | Medium | <label> prices to the reference formula |
| 67 | BE/API | Medium | <label> prices to the reference formula |
| 68 | BE/API | Medium | <label> prices to the reference formula |
| 69 | BE/API | Medium | <label> prices to the reference formula |
| 70 | BE/API | High | A check-out on the check-in day is refused |
| 71 | BE/API | High | A stay that is not a whole number of nights is refused |
| 72 | BE/API | Medium | A quote for a room that does not exist is not found |
| 73 | BE/API | High | A room at an inactive hotel cannot be priced |
| 74 | BE/API | Medium | A check-out before the check-in is refused |
| 197 | BE/API | Medium | <label> prices to the reference formula |
| 198 | BE/API | Medium | <label> prices to the reference formula |
| 199 | BE/API | Medium | <label> prices to the reference formula |
| 200 | BE/API | Medium | <label> prices to the reference formula |
| 201 | BE/API | Medium | <label> prices to the reference formula |
| 202 | BE/API | Medium | <label> prices to the reference formula |
| 203 | BE/API | Medium | <label> prices to the reference formula |
| 204 | BE/API | Medium | <label> prices to the reference formula |
| 205 | BE/API | Medium | <label> prices to the reference formula |
| 206 | BE/API | Medium | <label> prices to the reference formula |
| 207 | BE/API | Medium | <label> prices to the reference formula |
| 208 | BE/API | Medium | <label> prices to the reference formula |
| 209 | BE/API | Medium | <label> prices to the reference formula |
| 210 | BE/API | Medium | <label> prices to the reference formula |
| 211 | BE/API | Medium | <label> prices to the reference formula |
| 212 | BE/API | Medium | <label> prices to the reference formula |
| 213 | BE/API | Medium | <label> prices to the reference formula |
| 214 | BE/API | Medium | <label> prices to the reference formula |
| 215 | BE/API | Medium | <label> prices to the reference formula |
| 216 | BE/API | Medium | <label> prices to the reference formula |
| 251 | BE/API | Medium | <label> prices to the reference formula |
| 252 | BE/API | Medium | <label> prices to the reference formula |
| 253 | BE/API | Medium | <label> prices to the reference formula |
| 254 | BE/API | Medium | <label> prices to the reference formula |
| 255 | BE/API | Medium | <label> prices to the reference formula |
| 256 | BE/API | Medium | <label> prices to the reference formula |
| 257 | BE/API | Medium | <label> prices to the reference formula |
| 258 | BE/API | Medium | <label> prices to the reference formula |
| 259 | BE/API | Medium | <label> prices to the reference formula |
| 260 | BE/API | Medium | <label> prices to the reference formula |
| 261 | BE/API | Medium | <label> prices to the reference formula |
| 262 | BE/API | Medium | <label> prices to the reference formula |
| 263 | BE/API | Medium | <label> prices to the reference formula |
| 264 | BE/API | Medium | <label> prices to the reference formula |
| 265 | BE/API | Medium | <label> prices to the reference formula |
| 266 | BE/API | Medium | <label> prices to the reference formula |
| 267 | BE/API | Medium | <label> prices to the reference formula |
| 268 | BE/API | Medium | <label> prices to the reference formula |
| 269 | BE/API | Medium | <label> prices to the reference formula |
| 270 | BE/API | Medium | <label> prices to the reference formula |
| 271 | BE/API | Medium | <label> prices to the reference formula |
| 272 | BE/API | Medium | <label> prices to the reference formula |
| 273 | BE/API | Medium | <label> prices to the reference formula |
| 274 | BE/API | Medium | <label> prices to the reference formula |
| 275 | BE/API | Medium | <label> prices to the reference formula |
| 276 | BE/API | Medium | <label> prices to the reference formula |
| 277 | BE/API | Medium | <label> prices to the reference formula |
| 278 | BE/API | Medium | <label> prices to the reference formula |
| 279 | BE/API | Medium | <label> prices to the reference formula |
| 280 | BE/API | Medium | <label> prices to the reference formula |
| 281 | BE/API | Medium | <label> prices to the reference formula |
| 282 | BE/API | Medium | <label> prices to the reference formula |
| 283 | BE/API | Medium | <label> prices to the reference formula |
| 284 | BE/API | Medium | <label> prices to the reference formula |
| 285 | BE/API | Medium | <label> prices to the reference formula |
| 286 | BE/API | Medium | <label> prices to the reference formula |
| 287 | BE/API | Medium | <label> prices to the reference formula |
| 288 | BE/API | Medium | <label> prices to the reference formula |
| 289 | BE/API | Medium | <label> prices to the reference formula |
| 290 | BE/API | Medium | <label> prices to the reference formula |
| 291 | BE/API | Medium | <label> prices to the reference formula |
| 292 | BE/API | Medium | <label> prices to the reference formula |
| 293 | BE/API | Medium | <label> prices to the reference formula |
| 294 | BE/API | Medium | <label> prices to the reference formula |
| 295 | BE/API | Medium | <label> prices to the reference formula |
| 296 | BE/API | Medium | <label> prices to the reference formula |
| 297 | BE/API | Medium | <label> prices to the reference formula |
| 298 | BE/API | Medium | <label> prices to the reference formula |
| 299 | BE/API | Medium | <label> prices to the reference formula |
| 300 | BE/API | Medium | <label> prices to the reference formula |
| 301 | BE/API | Medium | <label> prices to the reference formula |
| 302 | BE/API | Medium | <label> prices to the reference formula |
| 303 | BE/API | Medium | <label> prices to the reference formula |
| 304 | BE/API | Medium | <label> prices to the reference formula |
| 305 | BE/API | Medium | <label> prices to the reference formula |
| 306 | BE/API | Medium | <label> prices to the reference formula |
| 307 | BE/API | Medium | <label> prices to the reference formula |
| 308 | BE/API | Medium | <label> prices to the reference formula |
| 309 | BE/API | Medium | <label> prices to the reference formula |
| 310 | BE/API | Medium | <label> prices to the reference formula |
| 311 | BE/API | Medium | <label> prices to the reference formula |
| 312 | BE/API | Medium | <label> prices to the reference formula |
| 313 | BE/API | Medium | <label> prices to the reference formula |
| 314 | BE/API | Medium | <label> prices to the reference formula |
| 315 | BE/API | Medium | <label> prices to the reference formula |
| 316 | BE/API | Medium | <label> prices to the reference formula |
| 317 | BE/API | Medium | <label> prices to the reference formula |
| 318 | BE/API | Medium | <label> prices to the reference formula |
| 319 | BE/API | Medium | <label> prices to the reference formula |
| 320 | BE/API | Medium | <label> prices to the reference formula |
| 321 | BE/API | Medium | <label> prices to the reference formula |
| 322 | BE/API | Medium | <label> prices to the reference formula |
| 323 | BE/API | Medium | <label> prices to the reference formula |
| 324 | BE/API | Medium | <label> prices to the reference formula |
| 325 | BE/API | Medium | <label> prices to the reference formula |
| 326 | BE/API | Medium | <label> prices to the reference formula |
| 327 | BE/API | Medium | <label> prices to the reference formula |
| 328 | BE/API | Medium | <label> prices to the reference formula |
| 329 | BE/API | Medium | <label> prices to the reference formula |
| 330 | BE/API | Medium | <label> prices to the reference formula |
| 331 | BE/API | Medium | <label> prices to the reference formula |
| 332 | BE/API | Medium | <label> prices to the reference formula |
| 333 | BE/API | Medium | <label> prices to the reference formula |
| 334 | BE/API | Medium | <label> prices to the reference formula |
| 335 | BE/API | Medium | <label> prices to the reference formula |
| 336 | BE/API | Medium | <label> prices to the reference formula |
| 337 | BE/API | Medium | <label> prices to the reference formula |
| 338 | BE/API | Medium | <label> prices to the reference formula |
| 339 | BE/API | Medium | <label> prices to the reference formula |
| 340 | BE/API | Medium | <label> prices to the reference formula |
| 341 | BE/API | Medium | <label> prices to the reference formula |
| 342 | BE/API | Medium | <label> prices to the reference formula |
| 343 | BE/API | Medium | <label> prices to the reference formula |
| 344 | BE/API | Medium | <label> prices to the reference formula |
| 345 | BE/API | Medium | <label> prices to the reference formula |
| 346 | BE/API | Medium | <label> prices to the reference formula |
| 347 | BE/API | Medium | <label> prices to the reference formula |
| 348 | BE/API | Medium | <label> prices to the reference formula |
| 349 | BE/API | Medium | <label> prices to the reference formula |
| 350 | BE/API | Medium | <label> prices to the reference formula |
| 351 | BE/API | Medium | <label> prices to the reference formula |
| 352 | BE/API | Medium | <label> prices to the reference formula |
| 353 | BE/API | Medium | <label> prices to the reference formula |
| 354 | BE/API | Medium | <label> prices to the reference formula |
| 355 | BE/API | Medium | <label> prices to the reference formula |
| 356 | BE/API | Medium | <label> prices to the reference formula |
| 357 | BE/API | Medium | <label> prices to the reference formula |
| 358 | BE/API | Medium | <label> prices to the reference formula |
| 359 | BE/API | Medium | <label> prices to the reference formula |
| 360 | BE/API | Medium | <label> prices to the reference formula |
| 361 | BE/API | Medium | <label> prices to the reference formula |
| 362 | BE/API | Medium | <label> prices to the reference formula |
| 363 | BE/API | Medium | <label> prices to the reference formula |
| 364 | BE/API | Medium | <label> prices to the reference formula |
| 365 | BE/API | Medium | <label> prices to the reference formula |
| 366 | BE/API | Medium | <label> prices to the reference formula |
| 367 | BE/API | Medium | <label> prices to the reference formula |
| 368 | BE/API | Medium | <label> prices to the reference formula |
| 369 | BE/API | Medium | <label> prices to the reference formula |
| 370 | BE/API | Medium | <label> prices to the reference formula |
| 371 | BE/API | Medium | <label> prices to the reference formula |
| 372 | BE/API | Medium | <label> prices to the reference formula |
| 373 | BE/API | Medium | <label> prices to the reference formula |
| 374 | BE/API | Medium | <label> prices to the reference formula |
| 375 | BE/API | Medium | <label> prices to the reference formula |
| 376 | BE/API | Medium | <label> prices to the reference formula |
| 377 | BE/API | Medium | <label> prices to the reference formula |
| 378 | BE/API | Medium | <label> prices to the reference formula |
| 379 | BE/API | Medium | <label> prices to the reference formula |
| 380 | BE/API | Medium | <label> prices to the reference formula |
| 381 | BE/API | Medium | <label> prices to the reference formula |
| 382 | BE/API | Medium | <label> prices to the reference formula |
| 383 | BE/API | Medium | <label> prices to the reference formula |
| 384 | BE/API | Medium | <label> prices to the reference formula |
| 385 | BE/API | Medium | <label> prices to the reference formula |
| 386 | BE/API | Medium | <label> prices to the reference formula |
| 387 | BE/API | Medium | <label> prices to the reference formula |
| 388 | BE/API | Medium | <label> prices to the reference formula |
| 389 | BE/API | Medium | <label> prices to the reference formula |
| 390 | BE/API | Medium | <label> prices to the reference formula |
| 391 | BE/API | Medium | <label> prices to the reference formula |
| 392 | BE/API | Medium | <label> prices to the reference formula |
| 393 | BE/API | Medium | <label> prices to the reference formula |
| 394 | BE/API | Medium | <label> prices to the reference formula |
| 395 | BE/API | Medium | <label> prices to the reference formula |
| 396 | BE/API | Medium | <label> prices to the reference formula |
| 397 | BE/API | Medium | <label> prices to the reference formula |
| 398 | BE/API | Medium | <label> prices to the reference formula |
| 399 | BE/API | Medium | <label> prices to the reference formula |
| 400 | BE/API | Medium | <label> prices to the reference formula |

## mini-stay-booking (36)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 75 | BE/API | High | Holding a room returns a held booking |
| 76 | BE/API | High | Holding twice with one idempotency key makes one booking |
| 77 | BE/API | High | Holding without a token is unauthenticated |
| 78 | BE/API | High | A room at an inactive hotel cannot be held |
| 79 | BE/API | High | Confirming a hold takes the payment and confirms the booking |
| 80 | BE/API | High | Confirming an expired hold is refused and expires the hold |
| 81 | BE/API | Medium | A booking can be read back with its events |
| 82 | BE/API | Medium | A guest's booking list includes what they held |
| 83 | BE/API | High | The hotelier checks a confirmed guest in and out |
| 84 | BE/API | High | A guest cannot work the front desk |
| 85 | BE/API | High | A no-show is a hotelier action on a confirmed booking |
| 86 | BE/API | High | Cancelling a flexible booking well ahead refunds in full |
| 87 | BE/API | High | A non-refundable booking refunds nothing |
| 88 | BE/API | High | Cancelling an unpaid hold refunds nothing |
| 89 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 90 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 91 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 92 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 93 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 94 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 95 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 96 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 97 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 98 | BE/API | High | A confirmed booking cannot be confirmed again |
| 99 | BE/API | High | A held booking cannot be checked in before it is confirmed |
| 100 | BE/API | High | A checked-out booking cannot be cancelled |
| 101 | BE/API | Medium | A booking cannot be checked out before it is checked in |
| 102 | BE/API | Medium | A cancelled booking cannot be confirmed |
| 229 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 230 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 231 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 232 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 233 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 234 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 235 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 236 | BE/API | Medium | Cancelling a <label> booking refunds per policy |

## mini-stay-availability (34)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 103 | BE/API | High | A fresh night on the scarce room shows one available |
| 104 | BE/API | High | Holding the scarce room drops its availability to nought |
| 105 | BE/API | High | A second hold on the held scarce room is refused |
| 106 | BE/API | Medium | Confirming the held scarce room keeps availability at nought |
| 107 | BE/API | High | Cancelling frees the scarce room again |
| 108 | BE/API | High | An expired hold does not occupy the scarce room |
| 109 | BE/API | High | When many guests race for the last room exactly one wins |
| 110 | BE/API | High | The race is decided the same way every time |
| 111 | BE/API | High | A race for a room with several in stock fills exactly the stock |
| 112 | BE/API | High | An overlapping range cannot also take the scarce room |
| 113 | BE/API | High | The nights immediately after are free |
| 114 | BE/API | Medium | A one-night overlap of a longer stay is still a conflict |
| 115 | BE/API | High | A fresh night on a four-room type shows four available |
| 116 | BE/API | High | Filling a four-room type refuses the fifth hold |
| 117 | BE/API | Medium | Cancelling one of several restores one room |
| 118 | BE/API | Medium | A multi-night hold occupies every night of its range |
| 119 | BE/API | Medium | Availability of a check-out on the check-in day is refused |
| 120 | BE/API | Low | Availability of an unknown room is not found |
| 121 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 122 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 123 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 124 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 125 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 126 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 127 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 128 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 129 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 130 | BE/API | Medium | A freed room can be taken again |
| 237 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 238 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 239 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 240 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 241 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 242 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |

## mini-stay-security (18)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 131 | BE/API | High | Holding a room requires a guest token |
| 132 | BE/API | High | A forged guest token is refused |
| 133 | BE/API | High | A hotelier token is not accepted as a guest |
| 134 | BE/API | High | A guest token is not accepted at the front desk |
| 135 | BE/API | High | A guest cannot read another guest's booking |
| 136 | BE/API | High | A guest cannot cancel another guest's booking |
| 137 | BE/API | High | A guest cannot confirm another guest's booking |
| 138 | BE/API | High | A hotelier cannot work a hotel it does not own |
| 139 | BE/API | High | The admin overview rejects a guest token |
| 140 | BE/API | High | The admin booking list rejects a guest token |
| 141 | BE/API | High | A token that only extends the admin token is rejected |
| 142 | BE/API | High | The owning guest still reads their own booking |
| 143 | BE/API | High | The owning hotelier still checks a guest in |
| 144 | BE/API | Medium | Guest onboarding is open and issues a token |
| 145 | BE/API | Medium | A quote response never carries a bearer token |
| 146 | BE/API | Medium | A booking response never carries a bearer token |
| 147 | BE/API | Medium | A booking read never carries a bearer token |
| 148 | BE/API | Medium | The admin overview never carries a bearer token |

## mini-stay-fe (20)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 149 | FE/UI | High | The home page lists exactly the active hotels |
| 150 | FE/UI | High | The inactive hotel does not appear on the home page |
| 151 | FE/UI | Medium | Each hotel row shows a currency code |
| 152 | FE/UI | Low | The home page is not empty |
| 153 | FE/UI | High | A hotel page lists its room types |
| 154 | FE/UI | High | Room rates are shown in the hotel's currency |
| 155 | FE/UI | Medium | Each room shows its inventory and cancellation policy |
| 156 | FE/UI | Low | An unknown hotel page is not found |
| 157 | FE/UI | High | A booking page shows the total it was priced at |
| 158 | FE/UI | High | A booking page shows the nights and status |
| 159 | FE/UI | Medium | A booking page total is a currency amount |
| 160 | FE/UI | Low | An unknown booking page is not found |
| 161 | FE/UI | Medium | A <state> booking page shows that status |
| 162 | FE/UI | Medium | A <state> booking page shows that status |
| 163 | FE/UI | High | A guest's booking list shows the booking they held |
| 164 | FE/UI | Medium | Each booking row links to its booking page |
| 165 | FE/UI | Medium | A booking list total is a currency amount |
| 166 | FE/UI | High | The admin page shows the payment taken as a number |
| 167 | FE/UI | Medium | Every admin status count is a non-negative integer |
| 168 | FE/UI | Medium | A confirmed booking shows up in the admin counts |

## frankfurter-api (436)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 169 | BE/API | High | Converting at parity leaves the amount unchanged |
| 170 | BE/API | High | Converting at a half rate halves the amount |
| 171 | BE/API | High | Converting nothing is nothing |
| 172 | BE/API | High | An inexact conversion rounds half-up to the cent |
| 173 | BE/API | Medium | A rate above parity raises the amount |
| 174 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 175 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 176 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 177 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 178 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 179 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 180 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 181 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 182 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 183 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 184 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 185 | BE/API | High | The historical endpoint answers with rates |
| 186 | BE/API | High | The historical response is for one unit of the base currency |
| 187 | BE/API | High | The historical euro rate is a positive number |
| 188 | BE/API | Medium | The historical pound rate is a positive number |
| 189 | BE/API | High | The historical rate is stable across two reads |
| 190 | BE/API | High | A stay converted at the real historical euro rate is positive and consistent |
| 191 | BE/API | Medium | A stay converted at the real historical pound rate is positive and consistent |
| 192 | BE/API | High | The latest endpoint answers with a rates object |
| 193 | BE/API | Medium | The latest euro rate is a positive finite number |
| 194 | BE/API | Medium | The latest response names its date |
| 195 | BE/API | Low | Every latest rate is a positive number |
| 196 | BE/API | Low | The latest response is one unit of the base currency |
| 243 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 244 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 245 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 246 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 247 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 248 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 249 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 250 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 401 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 402 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 403 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 404 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 405 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 406 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 407 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 408 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 409 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 410 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 411 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 412 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 413 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 414 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 415 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 416 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 417 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 418 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 419 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 420 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 421 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 422 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 423 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 424 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 425 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 426 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 427 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 428 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 429 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 430 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 431 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 432 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 433 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 434 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 435 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 436 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 437 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 438 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 439 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 440 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 441 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 442 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 443 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 444 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 445 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 446 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 447 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 448 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 449 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 450 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 451 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 452 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 453 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 454 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 455 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 456 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 457 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 458 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 459 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 460 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 461 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 462 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 463 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 464 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 465 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 466 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 467 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 468 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 469 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 470 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 471 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 472 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 473 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 474 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 475 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 476 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 477 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 478 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 479 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 480 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 481 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 482 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 483 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 484 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 485 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 486 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 487 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 488 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 489 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 490 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 491 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 492 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 493 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 494 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 495 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 496 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 497 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 498 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 499 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 500 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 501 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 502 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 503 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 504 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 505 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 506 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 507 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 508 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 509 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 510 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 511 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 512 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 513 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 514 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 515 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 516 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 517 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 518 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 519 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 520 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 521 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 522 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 523 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 524 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 525 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 526 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 527 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 528 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 529 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 530 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 531 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 532 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 533 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 534 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 535 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 536 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 537 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 538 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 539 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 540 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 541 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 542 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 543 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 544 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 545 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 546 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 547 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 548 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 549 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 550 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 551 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 552 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 553 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 554 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 555 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 556 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 557 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 558 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 559 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 560 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 561 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 562 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 563 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 564 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 565 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 566 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 567 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 568 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 569 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 570 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 571 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 572 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 573 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 574 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 575 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 576 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 577 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 578 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 579 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 580 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 581 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 582 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 583 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 584 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 585 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 586 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 587 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 588 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 589 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 590 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 591 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 592 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 593 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 594 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 595 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 596 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 597 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 598 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 599 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 600 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 601 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 602 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 603 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 604 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 605 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 606 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 607 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 608 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 609 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 610 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 611 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 612 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 613 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 614 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 615 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 616 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 617 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 618 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 619 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 620 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 621 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 622 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 623 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 624 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 625 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 626 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 627 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 628 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 629 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 630 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 631 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 632 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 633 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 634 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 635 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 636 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 637 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 638 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 639 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 640 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 641 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 642 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 643 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 644 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 645 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 646 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 647 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 648 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 649 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 650 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 651 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 652 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 653 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 654 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 655 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 656 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 657 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 658 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 659 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 660 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 661 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 662 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 663 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 664 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 665 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 666 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 667 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 668 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 669 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 670 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 671 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 672 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 673 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 674 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 675 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 676 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 677 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 678 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 679 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 680 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 681 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 682 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 683 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 684 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 685 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 686 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 687 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 688 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 689 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 690 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 691 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 692 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 693 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 694 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 695 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 696 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 697 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 698 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 699 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 700 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 701 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 702 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 703 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 704 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 705 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 706 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 707 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 708 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 709 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 710 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 711 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 712 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 713 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 714 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 715 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 716 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 717 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 718 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 719 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 720 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 721 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 722 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 723 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 724 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 725 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 726 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 727 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 728 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 729 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 730 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 731 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 732 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 733 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 734 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 735 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 736 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 737 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 738 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 739 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 740 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 741 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 742 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 743 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 744 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 745 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 746 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 747 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 748 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 749 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 750 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 751 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 752 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 753 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 754 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 755 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 756 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 757 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 758 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 759 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 760 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 761 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 762 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 763 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 764 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 765 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 766 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 767 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 768 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 769 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 770 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 771 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 772 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 773 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 774 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 775 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 776 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 777 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 778 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 779 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 780 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 781 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 782 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 783 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 784 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 785 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 786 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 787 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 788 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 789 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 790 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 791 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 792 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 793 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 794 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 795 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 796 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 797 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 798 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 799 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 800 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
