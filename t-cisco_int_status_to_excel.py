#此程序主要用于将思科交换机show int status 输出至log文本的信息复制至excel中
#并根据接口状态将表格区分为不同的颜色

import xlsxwriter
import sys
import re
import os
from datetime import datetime

# 定义颜色常量
COLOR_GREEN = '#00FF00'
COLOR_BLUE = '#0000FF'
COLOR_RED = '#FF0000'
COLOR_YELLOW = '#FFFF00'

# 判断是否有文件作为参数输入
if len(sys.argv) == 1:
    print("此程序主要用于将思科交换机show int status 输出至log文本的信息复制至excel中\n请在", sys.argv[0], "后输入文件名")
    sys.exit(1)
else:
    print("请确保用作分析的文本只含有show interface status信息,若包含其它配置内容则输出有误")
    inputfile = sys.argv[1]

# 清理空行和标题行
with open(inputfile, 'r') as file:
    lines = file.readlines()

# 清理空行和同时包含 'Port' 和 'Name' 的行
lines = [line.strip() for line in lines if line.strip() and ('Port' not in line or 'Name' not in line)]

with open(inputfile, 'w') as file:
    file.write('\n'.join(lines))

# 关闭文件
file.close()

# 分列处理,将处理的文本每一列提取至一个文本文件
with open(inputfile, 'r') as file:
    lines = file.readlines()

#注意!!!!!!!!!!!!!!!!!
#注意!!!!!!!!!!!!!!!!!
#注意!!!!!!!!!!!!!!!!!
#需要根据实际文件修改截断的位置，不同型号的交换机截断位置可能不一样
temp_port = [line[0:13].strip() for line in lines]
temp_name = [line[13:32].strip() for line in lines]
temp_status = [line[32:45].strip() for line in lines]
temp_vlan = [line[45:56].strip() for line in lines]
temp_duplex = [line[56:63].strip() for line in lines]
temp_speed_type = [line[63:].strip() for line in lines]

with open('./temp_port.txt', 'w') as file:
    file.write('\n'.join(temp_port))

with open('./temp_name.txt', 'w') as file:
    file.write('\n'.join(temp_name))

with open('./temp_status.txt', 'w') as file:
    file.write('\n'.join(temp_status))

with open('./temp_vlan.txt', 'w') as file:
    file.write('\n'.join(temp_vlan))

with open('./temp_duplex.txt', 'w') as file:
    file.write('\n'.join(temp_duplex))

with open('./temp_Speed_Type.txt', 'w') as file:
    file.write('\n'.join(temp_speed_type))

# 获取当前时间
current_time = datetime.now().strftime("%Y%m%d%H%M%S")

# 构造文件名
file_name = f"result_{current_time}.xlsx"

# 打开xlsx文件以追加数据
workbook = xlsxwriter.Workbook(file_name)
worksheet = workbook.add_worksheet()

# 定义输入文件列表
input_files = ['temp_port.txt', 'temp_name.txt', 'temp_status.txt', 'temp_vlan.txt', 'temp_duplex.txt','temp_Speed_Type.txt']

# 冻结首行
worksheet.freeze_panes(1, 0)

# 写入xlsx第一行标题
titles = ['port', 'name', 'status', 'vlan', 'duplex', 'speed_type']
for col, title in enumerate(titles):
    worksheet.write(0, col, title)


# 设置单元格格式
cell_format_green = workbook.add_format({'bg_color': COLOR_GREEN})
cell_format_blue = workbook.add_format({'bg_color': COLOR_BLUE})
cell_format_red = workbook.add_format({'bg_color': COLOR_RED})
cell_format_yellow = workbook.add_format({'bg_color': COLOR_YELLOW})

column_widths = []  # 用于存储每一列的宽度

for col, input_file in enumerate(input_files):
    with open(input_file, 'r') as file:
        lines = file.readlines()

        for row, line in enumerate(lines):
            line = line.strip()
            worksheet.write(row + 1, col, line)

            # 设置单元格颜色
            if line == 'connected':
                worksheet.write(row + 1, col, line, cell_format_green)
            elif line == 'notconnect':
                worksheet.write(row + 1, col, line, cell_format_blue)
            elif line == 'disabled':
                worksheet.write(row + 1, col, line, cell_format_red)
            elif line == 'suspended':
                worksheet.write(row + 1, col, line, cell_format_yellow)

        # 获取每一列的最大宽度
        column_widths.append(max(len(line) for line in lines))

# 调整列宽度
for col, width in enumerate(column_widths):
    worksheet.set_column(col, col, width + 2)  # 添加额外的空间

workbook.close()

# 清理临时文件
file_paths = ['temp_port.txt', 'temp_name.txt', 'temp_status.txt', 'temp_vlan.txt', 'temp_duplex.txt', 'temp_Speed_Type.txt']

for file_path in file_paths:
    if os.path.exists(file_path):
        os.remove(file_path)

current_directory = os.getcwd()
print(f"结果已生成至: {current_directory}/{file_name}")
