import sys
import os
import time

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

from playwright.sync_api import sync_playwright

OUTPUT_DIR = r"c:\Users\ASUS TUF GAMING 15\Desktop\bra\لقطات الشاشة\الثيمات"
os.makedirs(OUTPUT_DIR, exist_ok=True)

THEMES = [
    ("neonSouk", "01_ثيم_سوق_النيون_CyberNeon", "سوق النيون"),
    ("royalNoir", "02_ثيم_الملكي_الأسود_RoyalNoir", "الملكي الأسود"),
    ("emeraldLounge", "03_ثيم_اللاونج_الزمردي_EmeraldLounge", "اللاونج الزمردي"),
    ("midnightCoral", "04_ثيم_مرجان_منتصف_الليل_MidnightCoral", "مرجان منتصف الليل"),
    ("pearlMajlis", "05_ثيم_مجلس_اللؤلؤ_PearlMajlis", "مجلس اللؤلؤ"),
    ("candyChaos", "06_ثيم_حلوى_وفوضى_CandyChaos", "حلوى وفوضى"),
    ("desertArcade", "07_ثيم_أركيد_الصحراء_DesertArcade", "أركيد الصحراء"),
    ("oceanMajlis", "08_ثيم_مجلس_المحيط_OceanMajlis", "مجلس المحيط"),
]

def run():
    print("=== بدء اختبار وتبديل الثيمات الثمانية عبر Playwright Automation ===")
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

        for idx, (theme_key, fname, arabic_name) in enumerate(THEMES, start=1):
            print(f"[{idx}/{len(THEMES)}] اختبار ثيم: {arabic_name} ({theme_key})...")
            
            # 1. Open Home with theme
            url_home = f"http://localhost:8088/?theme={theme_key}&t={time.time()}#/home"
            page.goto(url_home, wait_until="networkidle")
            time.sleep(3)
            page.screenshot(path=os.path.join(OUTPUT_DIR, f"{fname}_الرئيسية.png"))

            # 2. Open Settings Profile with theme
            url_profile = f"http://localhost:8088/?theme={theme_key}&t={time.time()}#/profile"
            page.goto(url_profile, wait_until="networkidle")
            time.sleep(2.5)
            page.screenshot(path=os.path.join(OUTPUT_DIR, f"{fname}_الإعدادات.png"))
            print(f"   -> [تم بنجاح] التقاط وتوثيق ثيم {arabic_name}.")

        browser.close()
        print("=== انتهت كافة اختبارات الثيمات بنجاح 100%! ===")

if __name__ == "__main__":
    run()
