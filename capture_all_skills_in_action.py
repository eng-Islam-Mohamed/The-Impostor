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

        print("Navigating to http://localhost:8085/#/skills-showcase ...")
        page.goto("http://localhost:8085/?v=skills_showcase_1#/skills-showcase", wait_until="networkidle")
        time.sleep(6)

        # 0. Showcase Hub
        page.screenshot(path=os.path.join(OUTPUT_DIR, "00_شاشة_استعراض_المهارات_التكتيكية_hub.png"))
        print("Captured: 00_hub")

        # 1. Jackpot Reveal
        page.mouse.click(206, 120) # Click Jackpot card in showcase
        time.sleep(2)
        page.mouse.click(206, 460) # Click Reveal card
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "01_ظهور_مهارة_الجاكبوت_أثناء_كشف_الدور.png"))
        print("Captured: 01_jackpot_reveal")

        # Back to showcase
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)

        # 2. Tactical Drain Reveal (Targeting Salem)
        page.mouse.click(206, 190)
        time.sleep(2)
        page.mouse.click(206, 460)
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "02_ظهور_مهارة_السطو_التكتيكي_مع_تحديد_الضحية_سالم.png"))
        print("Captured: 02_tactical_drain_reveal")

        # Back to showcase
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)

        # 3. Karma Backfire Reveal
        page.mouse.click(206, 260)
        time.sleep(2)
        page.mouse.click(206, 460)
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "03_ظهور_مهارة_الارتداد_العكسي_أثناء_الكشف.png"))
        print("Captured: 03_karma_backfire_reveal")

        # Back to showcase
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)

        # 4. Double Vote Reveal
        page.mouse.click(206, 330)
        time.sleep(2)
        page.mouse.click(206, 460)
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "04_ظهور_مهارة_مضاعفة_الصوت_بصوتين_أثناء_الكشف.png"))
        print("Captured: 04_double_vote_reveal")

        # Back to showcase
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)

        # 5. Outsider Second Chance Reveal
        page.mouse.click(206, 400)
        time.sleep(2)
        page.mouse.click(206, 460)
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "05_ظهور_مهارة_الفرصة_المزدوجة_لكرت_برا_السالفة.png"))
        print("Captured: 05_second_chance_outsider_reveal")

        # Back to showcase
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)

        # 6. Outsider Guess Attempt 1/2
        page.mouse.click(206, 540) # Click Attempt 1
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "06_تطبيق_الفرصة_المزدوجة_المحاولة_الأولى_في_التحدي_الأخير.png"))
        print("Captured: 06_second_chance_attempt_1")

        # Back to showcase
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)

        # 7. Outsider Guess Attempt 2/2 (Warning after 1st wrong attempt)
        page.mouse.click(206, 610) # Click Attempt 2
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "07_تطبيق_الفرصة_المزدوجة_تنبيه_المحاولة_الثانية_بعد_الخطأ.png"))
        print("Captured: 07_second_chance_attempt_2")

        # Back to showcase
        page.goto("http://localhost:8085/#/skills-showcase")
        time.sleep(2)

        # 8. Results Screen with Events
        page.mouse.click(206, 680) # Click Results with Events
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "08_شاشة_النتائج_توثيق_أحداث_المهارات_الجاكبوت_والسطو_والارتداد.png"))
        print("Captured: 08_results_power_events")

        # 9. Results Screen Scoreboard
        page.mouse.wheel(0, 320)
        time.sleep(1)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "09_شاشة_النتائج_لوحة_النقاط_بعد_تصفير_ضحية_السطو_وزيادة_الجاكبوت.png"))
        print("Captured: 09_results_scoreboard_drained")

        browser.close()
        print("All skill action screenshots captured successfully!")

if __name__ == "__main__":
    run()
