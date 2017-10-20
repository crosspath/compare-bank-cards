require_relative '../../loader.rb'

current_date = Date.new(2017, 9, 1)

beeline = MagnateExamples::BankCards::BeelineCard.new(
  sum: 85_000, # 85 000 рублей изначально на счету
  unit: :rur,
  name: 'Билайн',
  current_date: current_date
)
sber = MagnateExamples::BankCards::SberbankElectron.new(
  sum: 10_000,
  unit: :rur,
  name: 'Сбербанк',
  current_date: current_date
)
cash = Magnate::CashAccount.new(
  sum: 5_000,
  unit: :rur,
  name: 'Наличные',
  current_date: current_date
)

holder = Magnate::AccountsHolder.new(accounts: [beeline, sber, cash])

# => 2017-09-01

beeline.add_operation(400, MCC::EATING_PLACES, 'Кафе или ресторан')
holder.next_day!

# => 2017-09-02

beeline.add_operation(44, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-03

beeline.add_operation(643, MCC::DRUG_STORES, 'Аптека')
beeline.add_operation(549, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-04

beeline.add_operation(345, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
beeline.add_operation(700, MCC::EATING_PLACES, 'Ресторан в парке')
beeline.add_operation(162, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-05

beeline.add_operation(250, MCC::EATING_PLACES, 'Киргизская кухня')
holder.next_day!

# => 2017-09-06

beeline.add_operation(420, MCC::EATING_PLACES, 'Кафе или ресторан')
sber.add_operation(4_753, nil, 'ЖКХ') # перевод юридическому лицу
beeline.add_operation(1700, MCC::LOCAL_SUBURBAN, 'Абонемент на метро')
holder.next_day!

# => 2017-09-07

beeline.add_operation(300, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.add_operation(427, MCC::GROCERY_STORES, 'Продукты')
sber.add_operation(289, nil, 'Электричество') # перевод юридическому лицу
holder.next_day!

# => 2017-09-08

beeline.add_operation(200, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.add_operation(350, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
holder.next_day!

# => 2017-09-09

beeline.add_operation(330, MCC::COMPUTER_NETWORK, 'Интернет')
beeline.add_operation(379, MCC::GROCERY_STORES, 'Продукты')
beeline.add_operation(22, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-10

beeline.add_operation(46, MCC::GROCERY_STORES, 'Продукты')
beeline.add_operation(66, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-11

beeline.add_operation(250, MCC::EATING_PLACES, 'Киргизская кухня')
holder.next_day!

# => 2017-09-12

beeline.add_operation(430, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.add_operation(216, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-13

beeline.add_operation(233, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.add_operation(380, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-14

holder.next_day!

# => 2017-09-15

beeline.add_operation(550, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.add_operation(820, MCC::EATING_PLACES, 'Ресторан')
holder.next_day!

# => 2017-09-16

beeline.add_operation(176, MCC::GROCERY_STORES, 'Продукты')
beeline.add_operation(645, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-17

beeline.add_operation(415, MCC::EATING_PLACES, 'Кафе или ресторан')
holder.next_day!

# => 2017-09-18

beeline.add_operation(250, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.add_operation(1009, MCC::EATING_PLACES, 'Ресторан')
holder.next_day!

# => 2017-09-19

beeline.add_operation(230, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
beeline.add_operation(250, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.add_operation(373, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-20

beeline.add_operation(26_500, nil, 'Аренда') # перевод физическому лицу
beeline.add_operation(445, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.add_operation(648, MCC::GROCERY_STORES, 'Продукты')
cash.add_operation(2_600, nil, 'Абонемент на групповые занятия')
holder.next_day!

# => 2017-09-21

beeline.add_operation(555, MCC::EATING_PLACES, 'Кафе или ресторан')
holder.next_day!

# => 2017-09-22

beeline.add_operation(495, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
beeline.add_operation(80, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-23

beeline.add_operation(210, MCC::GROCERY_STORES, 'Продукты')
beeline.add_operation(22, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-24

beeline.add_operation(22, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-25

beeline.add_operation(456, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
beeline.add_operation(599, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-26

beeline.add_operation(510, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.add_operation(332, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-27

beeline.add_operation(250, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.add_operation(286, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
holder.next_day!

# => 2017-09-28

beeline.add_operation(169, MCC::GROCERY_STORES, 'Продукты')
beeline.add_operation(846, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-29

beeline.add_operation(235, MCC::EATING_PLACES, 'Киргизская кухня')
holder.next_day!

# => 2017-09-30

beeline.add_operation(44, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# results

holder.put_log
# => table
# Date | Билайн | Сбербанк | Наличные | Sum
