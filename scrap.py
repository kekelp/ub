from selenium import webdriver
# from beautifulsoup4 import beautifulsoup4
import pandas as pd
import time
driver = webdriver.Chrome("/usr/lib/chromium/chromedriver")

driver.get("https://www.twitch.tv/popout/even_further_beyond/chat?popout=")

time_to_sleep = 4
time_slept = 0
while time_slept <= time_to_sleep:
    print("sleepy time ", time_to_sleep - time_slept)
    time.sleep(1)
    time_slept += 1

thinking = driver.find_element_by_class_name("text-fragment") 

print(thinking)

driver.close()