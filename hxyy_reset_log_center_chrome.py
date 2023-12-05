
#此程序主要为登陆信锐NAC后重启数据中心
#定位网页元素可以通过chrome 右键检查，复制完整xpath
#linux下需要先安装好chrome并确保/usr/bin/google-chrome 有可执行的二进制文件
#https://vikyd.github.io/download-chromium-history-version/#/ 下载chrome和chrome-driver
#下载地址wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
#yum install -y google-chrome-stable_current_x86_64.rpm
#google-chrome --version 确认安装正常
#chromedriver 下载地址https://chromedriver.chromium.org/downloads ，需确保和chrome版本一致

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
import time


def print_with_timestamp(text):
    current_time = datetime.datetime.now()
    formatted_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{formatted_time}] {text}")

# 禁用浏览器的证书验证
options = Options()
import datetime
options.add_argument('--ignore-certificate-errors')
# 设置Chrome浏览器隐藏界面
options.add_argument("--headless")
options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36")
options.add_argument("lang = zh_CN.UTF - 8")
options.add_argument("--window-size=1920,1080")
options.add_argument("--start-maximized")
# 初始化浏览器驱动
driver = webdriver.Chrome(options=options)
#driver = webdriver.Chrome(executable_path='/path/to/chromedriver', options=options)

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
time.sleep (10)
print_with_timestamp("日志中心重启完成")
# 关闭浏览器
driver.quit()

