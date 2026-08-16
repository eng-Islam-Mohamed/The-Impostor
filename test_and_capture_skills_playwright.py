import sys
import os
import time

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

from playwright.sync_api import sync_playwright

OUTPUT_DIR = r"c:\Users\ASUS TUF GAMING 15\Desktop\bra\لقطات الشاشة"
os.makedirs(OUTPUT_DIR, exist_ok=True)

SKILLS_TEST_CASES = [
    {
        "route": "jackpot",
        "filename": "01_ظهور_مهارة_الجاكبوت_أثناء_كشف_الدور.png",
        "description": "كشف الدور السري - مهارة الجاكبوت لحصد مجموع نقاط الجميع",
        "scroll": False,
    },
    {
        "route": "drain",
        "filename": "02_ظهور_مهارة_السطو_التكتيكي_مع_تحديد_الضحية_سالم.png",
        "description": "كشف الدور السري - مهارة السطو التكتيكي مع استهداف سالم وتصفير رصيده",
        "scroll": False,
    },
    {
        "route": "karma",
        "filename": "03_ظهور_مهارة_الارتداد_العكسي_أثناء_الكشف.png",
        "description": "كشف الدور السري - مهارة الارتداد العكسي لمعاقبة المتهمين بالخصم",
        "scroll": False,
    },
    {
        "route": "double-vote",
        "filename": "04_ظهور_مهارة_مضاعفة_الصوت_بصوتين_أثناء_الكشف.png",
        "description": "كشف الدور السري - مهارة صوتك يحسب بصوتين (+2 صواب / -2 خطأ)",
        "scroll": False,
    },
    {
        "route": "outsider-chance",
        "filename": "05_ظهور_مهارة_الفرصة_المزدوجة_لكرت_برا_السالفة.png",
        "description": "كشف كرت برا السالفة - مهارة الفرصة المزدوجة لمحاولتين في التحدي الأخير",
        "scroll": False,
    },
    {
        "route": "attempt-1",
        "filename": "06_تطبيق_الفرصة_المزدوجة_المحاولة_الأولى_في_التحدي_الأخير.png",
        "description": "التحدي الأخير لبرا السالفة - تفعيل الفرصة المزدوجة (المحاولة 1/2)",
        "scroll": False,
    },
    {
        "route": "attempt-2",
        "filename": "07_تطبيق_الفرصة_المزدوجة_تنبيه_المحاولة_الثانية_بعد_الخطأ.png",
        "description": "التحدي الأخير لبرا السالفة - تنبيه المحاولة الثانية (المحاولة 2/2 بعد الخطأ)",
        "scroll": False,
    },
    {
        "route": "results",
        "filename": "08_شاشة_النتائج_توثيق_أحداث_المهارات_الجاكبوت_والسطو_والارتداد.png",
        "description": "شاشة النتائج - أحداث المهارات التكتيكية وتطبيق الجاكبوت والسطو والارتداد",
        "scroll": False,
    },
    {
        "route": "scoreboard",
        "filename": "09_شاشة_النتائج_لوحة_النقاط_بعد_تصفير_ضحية_السطو_وزيادة_الجاكبوت.png",
        "description": "شاشة النتائج - لوحة النقاط التراكمية بعد تصفير الضحية سالم وحصد سارة للجاكبوت",
        "scroll": False,
    },
]

def run_playwright_test_loop():
    print("=== بدء فحص المهارات التكتيكية بالكامل عبر Playwright Automation ===")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 412, "height": 892},
            device_scale_factor=2,
            is_mobile=True,
            has_touch=True,
            locale="ar-SA"
        )
        page = context.new_page()

        # Step 0: Test Hub
        print("1. فحص شاشة استعراض المهارات الرئيسية...")
        page.goto("http://localhost:8085/?t=" + str(time.time()) + "#/skills-showcase", wait_until="networkidle")
        time.sleep(5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "00_شاشة_استعراض_المهارات_التكتيكية_hub.png"))
        print(" [OK] تم التقاط شاشة استعراض المهارات.")

        # Automation Loop over all skill test cases
        for idx, test in enumerate(SKILLS_TEST_CASES, start=1):
            url = f"http://localhost:8085/?t={time.time()}#/skills-showcase/{test['route']}"
            print(f"[{idx}/{len(SKILLS_TEST_CASES)}] اختبار: {test['description']}...")
            page.goto(url, wait_until="networkidle")
            time.sleep(3)

            if test.get("scroll", False):
                amount = test.get("scrollAmount", 360)
                page.mouse.wheel(0, amount)
                time.sleep(1.5)

            out_path = os.path.join(OUTPUT_DIR, test["filename"])
            page.screenshot(path=out_path)
            print(f" -> [نجاح] تم حفظ اللقطة: {test['filename']}")

        browser.close()
        print("=== انتهت كافة اختبارات Playwright بنجاح 100% ===")

if __name__ == "__main__":
    run_playwright_test_loop()
