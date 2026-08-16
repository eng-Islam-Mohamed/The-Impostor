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

def run():
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

        print("Navigating to showcase...")
        page.goto("http://localhost:8085/?v=precise_skills_1#/skills-showcase", wait_until="networkidle")
        time.sleep(6)

        # 0. Hub
        page.screenshot(path=os.path.join(OUTPUT_DIR, "00_شاشة_استعراض_المهارات_التكتيكية_hub.png"))
        print("Captured: 00_hub")

        # 1. Jackpot
        page.mouse.click(206, 180)
        time.sleep(2)
        page.mouse.click(206, 460) # Reveal
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "01_ظهور_مهارة_الجاكبوت_أثناء_كشف_الدور.png"))
        print("Captured: 01_jackpot")

        # 2. Tactical Drain
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)
        page.mouse.click(206, 290)
        time.sleep(2)
        page.mouse.click(206, 460) # Reveal
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "02_ظهور_مهارة_السطو_التكتيكي_مع_تحديد_الضحية_سالم.png"))
        print("Captured: 02_tactical_drain")

        # 3. Karma Backfire
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)
        page.mouse.click(206, 400)
        time.sleep(2)
        page.mouse.click(206, 460) # Reveal
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "03_ظهور_مهارة_الارتداد_العكسي_أثناء_الكشف.png"))
        print("Captured: 03_karma_backfire")

        # 4. Double Vote
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)
        page.mouse.click(206, 510)
        time.sleep(2)
        page.mouse.click(206, 460) # Reveal
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "04_ظهور_مهارة_مضاعفة_الصوت_بصوتين_أثناء_الكشف.png"))
        print("Captured: 04_double_vote")

        # 5. Outsider Second Chance
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)
        page.mouse.click(206, 640)
        time.sleep(2)
        page.mouse.click(206, 460) # Reveal
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "05_ظهور_مهارة_الفرصة_المزدوجة_لكرت_برا_السالفة.png"))
        print("Captured: 05_outsider_second_chance")

        # 6. Outsider Guess Attempt 1/2
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)
        page.mouse.wheel(0, 300)
        time.sleep(1)
        page.mouse.click(206, 540) # Attempt 1
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "06_تطبيق_الفرصة_المزدوجة_المحاولة_الأولى_في_التحدي_الأخير.png"))
        print("Captured: 06_attempt_1")

        # 7. Outsider Guess Attempt 2/2
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)
        page.mouse.wheel(0, 400)
        time.sleep(1)
        page.mouse.click(206, 350) # Attempt 2
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "07_تطبيق_الفرصة_المزدوجة_تنبيه_المحاولة_الثانية_بعد_الخطأ.png"))
        print("Captured: 07_attempt_2")

        # 8. Results Screen Events Breakdown
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)
        page.mouse.wheel(0, 400)
        time.sleep(1)
        page.mouse.click(206, 470) # Results with events
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "08_شاشة_النتائج_توثيق_أحداث_المهارات_الجاكبوت_والسطو_والارتداد.png"))
        print("Captured: 08_results_events")

        # 9. Results Scoreboard Breakdown
        page.mouse.wheel(0, 380)
        time.sleep(1)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "09_شاشة_النتائج_لوحة_النقاط_بعد_تصفير_ضحية_السطو_وزيادة_الجاكبوت.png"))
        print("Captured: 09_scoreboard")

        browser.close()
        print("All precise screenshots captured successfully!")

if __name__ == "__main__":
    run()
