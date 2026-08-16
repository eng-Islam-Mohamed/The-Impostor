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
    page.goto("http://localhost:8085/?t=" + str(time.time()) + "#/skills-showcase/results", wait_until="networkidle")
    time.sleep(3)

    # Drag to scroll down smoothly
    page.mouse.move(206, 750)
    page.mouse.down()
    page.mouse.move(206, 100, steps=15)
    page.mouse.up()
    time.sleep(1.5)

    out_path = os.path.join(OUTPUT_DIR, "09_شاشة_النتائج_لوحة_النقاط_بعد_تصفير_ضحية_السطو_وزيادة_الجاكبوت.png")
    page.screenshot(path=out_path)
    print("Scoreboard screenshot with drag captured successfully!")
    browser.close()
