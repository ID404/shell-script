
#此程序主要为登陆信锐NAC后重启数据中心
#定位网页元素可以通过chrome 右键检查，复制完整xpath
#linux下需要先安装好firefox
#yum install firefox
#同时需要下载geckodriver   下载地址 https://github.com/mozilla/geckodriver/releases
#geckodriver需要放在/usr/bin/ 下

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.firefox.options import Options
import time
import datetime

def print_with_timestamp(text):
    current_time = datetime.datetime.now()
    formatted_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{formatted_time}] {text}")

options = Options()
options.headless = True
options.set_preference("general.useragent.override", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Firefox/95.0")
options.add_argument("--width=0")
options.add_argument("--height=0")
driver = webdriver.Firefox(options=options)

# 打开需要登录的网页
print_with_timestamp("正在打开网页!")
driver.get("https://www.test.com/index.php/welcome/login")

# 输入用户名和密码
print_with_timestamp("输入用户名密码")
username_input = driver.find_element(By.ID,"login_user")
password_input = driver.find_element(By.ID,"login_password")
username_input.send_keys("admin")
password_input.send_keys("admin")

# 勾选checkbox
print_with_timestamp("勾选同意")
checkbox = driver.find_element(By.ID,"disclaimer")
checkbox.click()

# 判断checkbox是否被选中
wait = WebDriverWait(driver, 10)
#wait.until(EC.element_to_be_selected((By.ID, "disclaimer")))

# 点击登录按钮
print_with_timestamp("点击登录")
login_button = wait.until(EC.presence_of_element_located((By.ID,"sub")))
login_button.click()
time.sleep(10)

# 点击 系统维护 按钮
print_with_timestamp("点击系统维护")
system_main_button = driver.find_element(By.ID,"ext-gen40")
system_main_button.click()
time.sleep(10)

# 点击 重启及格式化 的按钮
print_with_timestamp("点击重启及格式化")
reload_format_button =  driver.find_element(By.CSS_SELECTOR, "span.b-cm-subnav-item-title[title='重启及格式化'][actionname='node']")
reload_format_button.click()
time.sleep(10)


# 点击 重启日志中心 按钮
print_with_timestamp("点击重启日志中心")
reboot_log_server_button = driver.find_element(By.XPATH, "//button[text()='重启日志中心']")
reboot_log_server_button.click()


time.sleep(10)

# 点击确定的按钮
print_with_timestamp("点击确定")
confirm_button = driver.find_element(By.XPATH, "/html/body/div[15]/div[2]/div[2]/div/div/div/div[1]/table/tbody/tr/td[1]/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/em/button")
#confirm_button = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[text()='确认']")))
#confirm_button = driver.find_element(By.XPATH, "//button[@type='button' and contains(@class, 'x-btn-text') and text()='确认']")
confirm_button.click()
print_with_timestamp("日志中心重启完成")
# 关闭浏览器
driver.quit()

