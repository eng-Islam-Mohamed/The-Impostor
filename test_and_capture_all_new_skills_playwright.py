import os
import sys
import time
from playwright.sync_api import sync_playwright

sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

OUTPUT_DIR = r"c:\Users\ASUS TUF GAMING 15\Desktop\bra\لقطات الشاشة\المهارات_الجديدة"
BASE_URL = "http://localhost:8088"

SCENARIOS = [
    {
        "url": f"{BASE_URL}/#/setup",
        "filename": "01_كثافة_المهارات_في_الإعدادات.png",
        "wait": 3.0,
        "scroll": 600,
        "title": "إعدادات كثافة توزيع المهارات"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/alliance",
        "filename": "02_مهارة_التحالف_التكتيكي.png",
        "wait": 3.0,
        "title": "كشف كرت التحالف التكتيكي"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/high-stakes",
        "filename": "03_مهارة_الرهان_العالي.png",
        "wait": 3.0,
        "title": "كشف كرت الرهان العالي"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/diplomatic-immunity",
        "filename": "04_مهارة_الحصانة_الدبلوماسية.png",
        "wait": 3.0,
        "title": "كشف كرت الحصانة الدبلوماسية"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/robin-hood",
        "filename": "05_مهارة_روبن_هود.png",
        "wait": 3.0,
        "title": "كشف كرت روبن هود"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/choices-focus",
        "filename": "06_مهارة_حصر_السبعة_خيارات.png",
        "wait": 3.0,
        "title": "كشف كرت حصر السبعة خيارات"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/choices-guess",
        "filename": "07_تطبيق_حصر_السبعة_خيارات_في_التخمين.png",
        "wait": 3.0,
        "title": "تطبيق حصر 7 خيارات في التحدي الأخير"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/drain",
        "filename": "08_مهارة_السطو_التكتيكي.png",
        "wait": 3.0,
        "title": "كشف كرت السطو التكتيكي (مجازفة السطو)"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/jackpot",
        "filename": "09_مهارة_الجاكبوت.png",
        "wait": 3.0,
        "title": "كشف كرت الجاكبوت"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/karma",
        "filename": "10_مهارة_الارتداد_العكسي.png",
        "wait": 3.0,
        "title": "كشف كرت الارتداد العكسي"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/double-vote",
        "filename": "11_مهارة_صوتك_بصوتين.png",
        "wait": 3.0,
        "title": "كشف كرت صوتك بصوتين"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/outsider-chance",
        "filename": "12_مهارة_الفرصة_المزدوجة.png",
        "wait": 3.0,
        "title": "كشف كرت الفرصة المزدوجة"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/results",
        "filename": "13_شاشة_النتائج_وتفصيل_الأحداث_التكتيكية.png",
        "wait": 3.0,
        "title": "شاشة النتائج وتفصيل أحداث المهارات"
    },
    {
        "url": f"{BASE_URL}/#/skills-showcase/scoreboard",
        "filename": "14_لوحة_الصدارة_بعد_تطبيق_النقاط.png",
        "wait": 3.0,
        "scroll": 1200,
        "title": "لوحة الصدارة بالنقاط التراكمية"
    },
]

def run_tests():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"Directory ready: {OUTPUT_DIR}")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 430, "height": 932},
            is_mobile=True,
            has_touch=True,
            device_scale_factor=2
        )
        page = context.new_page()

        for scenario in SCENARIOS:
            print(f"Navigating to {scenario['title']}: {scenario['url']}")
            page.goto(scenario['url'], wait_until="networkidle")
            time.sleep(scenario['wait'])

            if scenario.get("scroll"):
                page.mouse.wheel(0, scenario["scroll"])
                time.sleep(1.0)

            save_path = os.path.join(OUTPUT_DIR, scenario['filename'])
            page.screenshot(path=save_path, full_page=False)
            print(f"Captured: {save_path}")

        browser.close()
    print("All skill tests and screenshots completed successfully!")

if __name__ == "__main__":
    run_tests()
