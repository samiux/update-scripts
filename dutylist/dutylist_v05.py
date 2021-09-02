#!/bin/env python3

'''
Description : RCCC HKI Duty List Search
Author      : Samiux (https://samiux.github.io)
Date        : August 1, 2021
Version     : 0.5
'''

from datetime import date

# length of the list is 16
list = ['C1', 'C2', 'C3', 'C4', 'L ', 'TO', 'B1', 'B2', 'B3', 'B4', 'L ', 'A1', 'A2', 'A3', 'A4', 'L ']

# the day C1 as default of each team
'''
team 1 : 1990-08-05
team 2 : 1990-08-17
team 3 : 1990-08-13
team 4 : 1990-08-09
'''
default_date_list = [date(1990, 8, 5), date(1990, 8, 17), date(1990, 8, 13), date(1990, 8, 9)]

# title
print ('\nRCCC HKI Duty List Search (Version 0.5)\n(CTRL+c to quit)\n')

# data input and data validation
while True:
	try:
		target_date = date.fromisoformat(input('Enter the date (e.g. 2021-12-07): '))
		print ('')
	except ValueError:
		print ('ERROR : Invalid date or date format!\n')
		continue
	except KeyboardInterrupt:
		print ('\n')
		exit()
	else:
		break

# target date calculation
for i in range(4):
	num_of_date = target_date - default_date_list[(i)]
	day_pattern = num_of_date.days % 16
	result = list[day_pattern]

	# calculate for the next day
	if day_pattern < 15:
		next_day = list[day_pattern + 1]
	elif day_pattern == 15:
		next_day = list[day_pattern - 15]

	# print the result
	print ('Team %s' % (i + 1) + ': target day is %s' % result + ' and next day is %s' % next_day)

print ('')

