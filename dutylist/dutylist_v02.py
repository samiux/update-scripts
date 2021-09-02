#!/bin/env python3

'''
Description : RCCC HKI Duty List Search
Author      : Samiux
Date        : July 30, 2021
Version     : 0.2
'''

from datetime import date

# length of the list is 16
list = ['C1', 'C2', 'C3', 'C4', 'L', 'TO', 'B1', 'B2', 'B3', 'B4', 'L', 'A1', 'A2', 'A3', 'A4', 'L']

# the day C1 as default
default_date_t1 = date(1990, 8, 5)  # team 1
default_date_t2 = date(1990, 8, 17) # team 2
default_date_t3 = date(1990, 8, 13) # team 3
default_date_t4 = date(1990, 8, 9)  # team 4

default_date_list = [default_date_t1, default_date_t2, default_date_t3, default_date_t4]

# title
print ('RCCC HKI Duty List Search\n(CTRL+c to quit)\n')

# data input
while True:
	try:
		team = int(input('Enter the team number: '))
	except ValueError:
		print ('Invalid data!')
		continue
	except KeyboardInterrupt:
		print ('\n')
		exit()
	else:
		if team < 1 or team > 4:
			print ('Invalid team!')
			continue
		else:
			break

while True:
	try:
		year = int(input('Enter the year: '))
	except ValueError:
		print ('Invalid data!')
		continue
	except KeyboardInterrupt:
		print ('\n')
		exit()
	else:
		if year < 1991:
			print ('Invalid year!')
			continue
		else:
			break

while True:
	try:
		month = int(input('Enter the month: '))
	except ValueError:
		print ('Invalid data!')
		continue
	except KeyboardInterrupt:
		print ('\n')
		exit()
	else:
		if month < 1 or month > 12:
			print ('Invalid month!')
		else:
			break

while True:
	try:
		day = int(input('Enter the day: '))
	except ValueError:
		print ('Invalid data!')
		continue
	except KeyboardInterrupt:
		print ('\n')
		exit()
	else:
		if day < 1 or day > 31:
			print ('Invalid day!')
		else:
			break

# target date calculation
target_date = date(year, month, day)
num_of_date = target_date - default_date_list[(team - 1)]
day_pattern = num_of_date.days % 16
result = list[day_pattern]

# calculate for the next day
if day_pattern < 15:
	next_day = list[day_pattern + 1]
elif day_pattern == 15:
	next_day = list[day_pattern - 15]

# print the result
print ('The target pattern is: %s' % result + ' and next day is: %s' % next_day)

