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

        print("Navigating to http://localhost:8085 ...")
        page.goto("http://localhost:8085/?v=skills_test_2", wait_until="networkidle")
        time.sleep(6)

        # 1. Home screen
        page.screenshot(path=os.path.join(OUTPUT_DIR, "01_الشاشة_الرئيسية_home.png"))
        print("Captured: 01_home")

        # Click Start Game (بدء اللعبة)
        page.mouse.click(206, 420)
        time.sleep(2)

        # 2. Setup screen
        page.screenshot(path=os.path.join(OUTPUT_DIR, "02_إعداد_الجولة_والمهارات_الجديدة_setup.png"))
        print("Captured: 02_setup")

        # Scroll down to reveal all 5 skills clearly
        page.mouse.wheel(0, 300)
        time.sleep(1)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "03_قائمة_المهارات_الخمس_التكتيكية_skills_list.png"))
        print("Captured: 03_skills_list")

        # Click Next: Player Setup (التالي: إعداد اللاعبين)
        page.mouse.click(206, 840)
        time.sleep(2)

        # 4. Players screen
        page.screenshot(path=os.path.join(OUTPUT_DIR, "04_إعداد_اللاعبين_وتخصيص_الشخصيات_players.png"))
        print("Captured: 04_players")

        # Click Next: Choose Categories (التالي: اختيار الفئات)
        page.mouse.click(206, 840)
        time.sleep(2)

        # 5. Categories screen
        page.screenshot(path=os.path.join(OUTPUT_DIR, "05_اختيار_الفئة_شخصيات_وحضارات_categories.png"))
        print("Captured: 05_categories")

        # Click Start Round (بدء الجولة)
        page.mouse.click(206, 840)
        time.sleep(3)

        # 6. Reveal Screen Player 1 (Pass and Play)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "06_كشف_الدور_السري_اللاعب_الأول_pass_player1.png"))
        print("Captured: 06_pass_player1")

        # Click Reveal card for Player 1
        page.mouse.click(206, 460)
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "07_كشف_المهارة_والسالفة_اللاعب_الأول_reveal_p1.png"))
        print("Captured: 07_reveal_p1")

        # Click Next Player
        page.mouse.click(206, 840)
        time.sleep(2)

        # 8. Reveal Screen Player 2
        page.screenshot(path=os.path.join(OUTPUT_DIR, "08_كشف_الدور_السري_اللاعب_الثاني_pass_player2.png"))
        print("Captured: 08_pass_player2")

        # Click Reveal card for Player 2
        page.mouse.click(206, 460)
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "09_كشف_المهارة_والسالفة_اللاعب_الثاني_reveal_p2.png"))
        print("Captured: 09_reveal_p2")

        # Click Next Player
        page.mouse.click(206, 840)
        time.sleep(2)

        # 10. Reveal Screen Player 3
        page.screenshot(path=os.path.join(OUTPUT_DIR, "10_كشف_الدور_السري_اللاعب_الثالث_pass_player3.png"))
        print("Captured: 10_pass_player3")

        # Click Reveal card for Player 3
        page.mouse.click(206, 460)
        time.sleep(1.5)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "11_كشف_المهارة_والسالفة_اللاعب_الثالث_reveal_p3.png"))
        print("Captured: 11_reveal_p3")

        # Click Next / Start Clue Turns
        page.mouse.click(206, 840)
        time.sleep(2)

        # 12. Clue turns screen
        page.screenshot(path=os.path.join(OUTPUT_DIR, "12_مرحلة_أدوار_التلميحات_clue_turns.png"))
        print("Captured: 12_clue_turns")

        # Click Start Discussion (بدء النقاش)
        page.mouse.click(206, 840)
        time.sleep(2)

        # 13. Discussion screen
        page.screenshot(path=os.path.join(OUTPUT_DIR, "13_مرحلة_النقاش_المفتوح_discussion.png"))
        print("Captured: 13_discussion")

        # Click Proceed to Voting (الانتقال للتصويت)
        page.mouse.click(206, 840)
        time.sleep(2)

        # 14. Voting Screen Player 1
        page.screenshot(path=os.path.join(OUTPUT_DIR, "14_مرحلة_التصويت_اللاعب_الأول_voting_p1.png"))
        print("Captured: 14_voting_p1")

        # Select suspect 1 and confirm vote
        page.mouse.click(100, 360) # Pick first candidate card
        time.sleep(1)
        page.mouse.click(206, 840) # Confirm vote
        time.sleep(2)

        # 15. Voting Screen Player 2
        page.screenshot(path=os.path.join(OUTPUT_DIR, "15_مرحلة_التصويت_اللاعب_الثاني_voting_p2.png"))
        print("Captured: 15_voting_p2")

        # Select suspect 2 and confirm vote
        page.mouse.click(100, 360)
        time.sleep(1)
        page.mouse.click(206, 840)
        time.sleep(2)

        # 16. Voting Screen Player 3
        page.screenshot(path=os.path.join(OUTPUT_DIR, "16_مرحلة_التصويت_اللاعب_الثالث_voting_p3.png"))
        print("Captured: 16_voting_p3")

        # Select suspect 3 and confirm vote
        page.mouse.click(100, 360)
        time.sleep(1)
        page.mouse.click(206, 840)
        time.sleep(2)

        # 17. Suspense Phase
        page.screenshot(path=os.path.join(OUTPUT_DIR, "17_شاشة_الترقب_وحبس_الأنفاس_suspense.png"))
        print("Captured: 17_suspense")

        # Wait for suspense timer to finish (around 4.5 seconds)
        time.sleep(5)

        # 18. Outsider Final Guessing Phase
        page.screenshot(path=os.path.join(OUTPUT_DIR, "18_التحدي_الأخير_لبرا_السالفة_outsider_guess.png"))
        print("Captured: 18_outsider_guess")

        # Pick a topic guess card
        page.mouse.click(100, 420)
        time.sleep(1)
        page.mouse.click(206, 840) # Confirm guess
        time.sleep(3)

        # 19. Results Screen
        page.screenshot(path=os.path.join(OUTPUT_DIR, "19_شاشة_النتائج_وأحداث_المهارات_والنقاط_results.png"))
        print("Captured: 19_results")

        # Scroll down in results to show full scoreboard and buttons
        page.mouse.wheel(0, 350)
        time.sleep(1)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "20_شاشة_النتائج_لوحة_النقاط_التراكمية_scoreboard.png"))
        print("Captured: 20_scoreboard")

        # Return to Home
        page.mouse.click(206, 840)
        time.sleep(2)

        # Navigate to Store (/store)
        page.goto("http://localhost:8085/#/store")
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "21_المتجر_وحزم_المعرفة_store.png"))
        print("Captured: 21_store")

        # Navigate to Stats (/stats)
        page.goto("http://localhost:8085/#/stats")
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "22_سجل_الإحصائيات_ولوحة_المتصدرين_stats.png"))
        print("Captured: 22_stats")

        # Navigate to Settings (/profile)
        page.goto("http://localhost:8085/#/profile")
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "23_الإعدادات_وتبديل_الثيمات_settings.png"))
        print("Captured: 23_settings")

        # Navigate to Subject Library (/setup/manage-subjects)
        page.goto("http://localhost:8085/#/setup/manage-subjects")
        time.sleep(2)
        page.screenshot(path=os.path.join(OUTPUT_DIR, "24_إدارة_مكتبة_السوالف_والفئات_subjects.png"))
        print("Captured: 24_subjects")

        browser.close()
        print("All 24 screenshots captured successfully!")

if __name__ == "__main__":
    run()
