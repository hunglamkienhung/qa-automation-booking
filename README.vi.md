# qa-automation-booking

![Pytest-BDD](https://img.shields.io/badge/Pytest--BDD-tests-0A9EDC?logo=pytest&logoColor=white)
![Cucumber](https://img.shields.io/badge/Cucumber-BDD-23D96C?logo=cucumber&logoColor=white)
![Playwright](https://img.shields.io/badge/Playwright-E2E-2EAD33?logo=playwright&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-store-003B57?logo=sqlite&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Node](https://img.shields.io/badge/Node-24-5FA04E?logo=nodedotjs&logoColor=white)
[![CI](https://github.com/hunglamkienhung/qa-automation-booking/actions/workflows/ci.yml/badge.svg)](https://github.com/hunglamkienhung/qa-automation-booking/actions/workflows/ci.yml)

Bộ QA automation cho một domain **đặt phòng khách sạn**, dựng như một hệ thống
chạy được chứ không phải slide trình chiếu. Một dịch vụ đặt phòng với điều phần
mềm này tuyệt đối không được làm — **bán một phòng hai lần cho cùng một đêm** —
được chứng minh đúng ngay cả khi nhiều khách cùng giành phòng cuối. Được kiểm ở
**mọi tầng nó có** (database, API, giao diện) bởi **hai stack độc lập** (Node +
Cucumber, Python + pytest-bdd) cùng đọc **một** bộ Gherkin và phải cho **cùng một
kết luận cho mọi case**.

Không cần tài khoản, không cần key, không cần dịch vụ trả phí. Clone về là chạy.

[English](README.md) · [Chấm điểm](docs/GRADING.md) ·
[Gherkin](docs/GHERKIN.md) · [Định dạng hàng đợi](docs/QUEUE-FORMAT.md)

## Hai hệ thống được kiểm

| Hệ thống | Truy cập | Là gì |
|---|---|---|
| **mini-stay** | đọc + ghi, DB thật | Backend đặt phòng nhỏ trong `services/mini-stay`: một file SQLite, chỉ dùng thư viện chuẩn của Node, REST API cho tìm kiếm, giữ chỗ, vòng đời đặt phòng và hủy, cùng các trang HTML gắn nhãn cho Playwright. |
| **frankfurter.dev** | chỉ đọc, live | API tỉ giá live, không cần key (tỉ giá tham chiếu ECB). Một tỉ giá lịch sử đã chốt dùng để quy đổi giá một kỳ nghỉ; không ai chỉnh cho nó "pass" được. |

**250 case**, mỗi case một ID bất biến, chạy trên **cả hai** stack và đối chiếu
từng case. Mọi tầng dịch vụ có đều được kiểm ở đúng tầng đó:

| Tầng | Đích | Case | Ở đâu |
|---|---|---|---|
| DB | SQLite mini-stay, đọc trực tiếp | 52 | `be/db` |
| API | tính giá — số đêm × giá + thuế basis-point nguyên | 54 | `be/api` |
| API | vòng đời đặt phòng — giữ chỗ, xác nhận, check-in/out, hủy, hết hạn, no-show | 36 | `be/api` |
| API | tồn phòng — không overbooking, kể cả khi đồng thời | 34 | `be/api` |
| API | ranh giới phân quyền (security) | 18 | `be/api` |
| API | Frankfurter + phép quy đổi dựng trên nó | 36 | `be/api` |
| FE | các trang app mini-stay (Playwright) | 20 | `fe/ui` |
| | **Tổng** | **250** | |

## Bất biến đáng giá cả repo

**Không phòng nào bị bán quá số lượng tồn cho bất kỳ đêm nào.** Tồn phòng là số
phòng của một loại còn trống cho mọi đêm trong khoảng, tính cả kỳ nghỉ đã xác
nhận và các hold còn sống, nhưng KHÔNG tính hold đã hết hạn. Một hold chỉ được
chấp nhận nếu có phòng trống cho cả khoảng, và phép kiểm cùng phép chèn diễn ra
trong **một giao dịch `BEGIN IMMEDIATE`**. Nên khi nhiều khách cùng bắn hold vào
phòng cuối **cùng một thời điểm**, chúng bị tuần tự hoá và **đúng một người
thắng** — tầng availability chứng minh bằng một cuộc đua thật (`Promise.all` ở
Node, một thread pool ở Python) và assert số người thắng bằng ĐÚNG số phòng tồn,
không hơn. Khoảng ngày chồng lấn thì xung đột; khoảng liền kề thì không; một hold
hết hạn giải phóng phòng; một lần hủy giải phóng phòng.

## Tiền và cỗ máy

`mini-stay` là nơi có các đường **ghi**, và nó cố ý chính xác.

**Tính giá là số học nguyên.** Một kỳ nghỉ = số đêm nhân giá phòng mỗi đêm, cộng
thuế của khách sạn tính bằng basis-point nguyên trên phần đó, làm tròn nửa-lên
tới xu — nên giá chính xác và cả hai stack khớp. Tầng tính giá ghim bằng số vàng
và đối chiếu với một bản tự cài lại độc lập trên cả một lưới phòng và độ dài.

**Một lần hủy hoàn một phần tuỳ chính sách và thời điểm.** Mỗi phòng mang một
chính sách hủy (linh hoạt, vừa phải, không hoàn); mức hoàn tuỳ chính sách và tuỳ
còn bao nhiêu ngày trọn trước khi nhận phòng, tính bằng xu nguyên. Giá, thuế và
chính sách được chụp ảnh (snapshot) vào booking, nên thay đổi giá sau này không
bao giờ ghi lại tiền của một booking đã có.

**Một booking chạy máy trạng thái có cổng và có audit.** `held → confirmed →
checked_in → checked_out`, với `cancelled`, `expired` (hold hết hạn trước khi
xác nhận) và `no_show` là các nhánh thoát. Mỗi chuyển trạng thái bị chặn theo
**bạn là ai** (chỉ lễ tân mới check-in khách) và theo **đang ở trạng thái nào**,
và mỗi chuyển được ghi vào `booking_events`; xác nhận thì thu tiền, hủy thì ghi
hoàn, cả hai vào một `ledger`.

**Tầng security** dò API như kẻ tấn công — request không token, token giả, token
sai vai, hoặc token hợp lệ nhưng cho booking/khách sạn không phải của mình đều bị
từ chối (401 chưa xác thực, 403 bị cấm, 404 khi câu trả lời thậm chí không được
để lộ booking tồn tại), kèm ca đối chứng dương để chắc đó là cổng thật.

**Tầng live** đọc Frankfurter không cần key. Một tỉ giá **lịch sử** đã chốt được
assert theo giá trị và theo tính ổn định qua hai lần đọc; tỉ giá **mới nhất** đổi
theo thị trường nên chỉ assert hình dạng và khoảng. Một hàm thuần
`convert(cents, rate)` quy đổi giá sang tiền tệ khác bằng xu nguyên, và quy đổi
một tổng kỳ nghỉ thật ở một tỉ giá lịch sử thật cho thấy đường đa-tiền-tệ
đầu-cuối.

## Hai ý đáng dừng lại một phút

**Một bộ Gherkin, hai stack, một kết luận.** `features/*.feature` dùng chung.
`node/` chạy bằng Cucumber; `python/` chạy chính các file đó bằng pytest-bdd. Một
case lệch nhau giữa hai bên tự nó là một phát hiện — và build fail vì điều đó.

**Failed > Blocked > Passed, và sự cố hạ tầng không bao giờ là fail.** Một case
Failed chỉ khi một mệnh đề quan sát được là sai. Khi nguồn live (Frankfurter, một
service đang tắt) không truy cập được, case là **Blocked**, không phải Failed —
nên mạng chập chờn không thể giả dạng nghiệp vụ hỏng. Cổng CI kiểm *hình dạng*
lượt chạy so với `fixtures/expected-results.json`. Xem
[docs/GRADING.md](docs/GRADING.md).

## Chạy trong 30 giây

```bash
# lõi chấm điểm dùng chung, cả hai stack
cd core/node && node --test "selftest/*.test.js"
cd ../python && pip install -e . && python -m pytest selftest -q
```

## Chạy cả bộ

Mỗi bước dưới đây đúng là thứ CI chạy (`scripts/*.sh`), nên chạy tay cũng được.

```bash
# backend, một stack, không cần trình duyệt (seed mini-stay, rồi DB + tính giá + đặt phòng + tồn phòng + security + Frankfurter)
bash scripts/run-be.sh node       # hoặc: python

# các trang app (tự cài chromium)
bash scripts/run-fe.sh node       # hoặc: python

# cả bộ, rồi verify hình dạng lượt chạy so với baseline
bash scripts/gate.sh node
```

Chạy tay từng tầng:

```bash
( cd services/mini-stay && bash serve.sh up )    # service seed mới
cd node && QA_DOMAIN_ROOT=.. npx cucumber-js --tags "@be and @availability"
```

Yêu cầu: Node ≥ 22.13 (cho `node:sqlite`) và Python ≥ 3.11. Script FE tự cài trình
duyệt. Có sẵn devcontainer đủ bộ trong
[.devcontainer/](.devcontainer/devcontainer.json). Có bộ load-test Locust trong
[perf/](perf/README.md).

## Bố cục

```
core/            một lõi chấm điểm/hàng đợi/báo cáo/bugflow, vendored vào repo này
services/
  mini-stay/     SQLite + REST + HTML — dịch vụ đặt phòng được kiểm
features/        một bộ Gherkin, dùng chung cả hai stack
fixtures/        testcases.json (ID) · expected-results.json (hình dạng)
node/  python/   hai stack: be/{db,api} fe/ui
testcases/       catalogue sinh từ features (không bao giờ lệch)
perf/            một bộ load-test Locust có cổng pass/fail
scripts/         đúng các lệnh CI chạy; tái lập được bằng tay
docs/            luật chấm điểm, quy ước Gherkin, định dạng hàng đợi
.github/workflows/ci.yml
```

## Ghi chú

- Các assert về giá, hoàn tiền và quy đổi không đọc lại con số của chính service —
  chúng **tự tính lại** bằng đúng số học nguyên rồi so, nên một lỗi đấu nối hay
  làm tròn sẽ lộ ra thành lệch.
- Vòng đời được kiểm từ ba phía: tầng API lái các chuyển trạng thái và assert cổng
  vai trò cùng mã lỗi; tầng DB đọc thẳng audit `booking_events` và `ledger`; tầng
  FE đọc trang khách sạn, trang booking và trang admin rồi đối chiếu với cùng các dòng.
- Mỗi scenario lấy một đêm tương lai mới nên không bao giờ tranh chấp với scenario
  khác, trừ khi nó cố ý cho hai booking giành cùng những đêm.
- Catalogue được sinh từ các file feature bởi `testcases/build.js`, nên không thể
  lệch khỏi thứ thực sự chạy — CI kiểm bằng `--check`.

## Phạm vi trung thực

Tầng nguồn-live (Frankfurter) phụ thuộc bên thứ ba có thể chậm hoặc không truy cập
được; các case đó được viết để chấm **Blocked**, không phải Failed, khi điều đó
xảy ra, và logic quy đổi dựng trên nó là một hàm thuần được kiểm tất định không
cần mạng. Service mini-stay tự viết thì hoàn toàn tất định và là nơi kiểm việc
tính giá, máy trạng thái, các bất biến về tiền, đảm bảo không overbooking và ranh
giới phân quyền.
