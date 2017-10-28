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

beeline.purchase(400, MCC::EATING_PLACES, 'Кафе или ресторан')
holder.next_day!

# => 2017-09-02

beeline.purchase(44, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-03

beeline.purchase(643, MCC::DRUG_STORES, 'Аптека')
beeline.purchase(549, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-04

beeline.purchase(345, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
beeline.purchase(700, MCC::EATING_PLACES, 'Ресторан в парке')
beeline.purchase(162, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-05

beeline.purchase(250, MCC::EATING_PLACES, 'Киргизская кухня')
holder.next_day!

# => 2017-09-06

beeline.purchase(420, MCC::EATING_PLACES, 'Кафе или ресторан')
sber.send_transfer_to_org(4_753, 'ЖКХ') # перевод юридическому лицу
beeline.purchase(1700, MCC::LOCAL_SUBURBAN, 'Абонемент на метро')
holder.next_day!

# => 2017-09-07

beeline.purchase(300, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.purchase(427, MCC::GROCERY_STORES, 'Продукты')
sber.send_transfer_to_org(289, 'Электричество') # перевод юридическому лицу
holder.next_day!

# => 2017-09-08

beeline.purchase(200, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.purchase(350, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
holder.next_day!

# => 2017-09-09

beeline.purchase(330, MCC::COMPUTER_NETWORK, 'Интернет')
beeline.purchase(379, MCC::GROCERY_STORES, 'Продукты')
beeline.purchase(22, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-10

beeline.purchase(46, MCC::GROCERY_STORES, 'Продукты')
beeline.purchase(66, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-11

beeline.purchase(250, MCC::EATING_PLACES, 'Киргизская кухня')
holder.next_day!

# => 2017-09-12

beeline.purchase(430, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.purchase(216, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-13

beeline.purchase(233, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.purchase(380, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-14

holder.next_day!

# => 2017-09-15

beeline.purchase(550, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.purchase(820, MCC::EATING_PLACES, 'Ресторан')
holder.next_day!

# => 2017-09-16

beeline.purchase(176, MCC::GROCERY_STORES, 'Продукты')
beeline.purchase(645, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-17

beeline.purchase(415, MCC::EATING_PLACES, 'Кафе или ресторан')
holder.next_day!

# => 2017-09-18

beeline.purchase(250, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.purchase(1009, MCC::EATING_PLACES, 'Ресторан')
holder.next_day!

# => 2017-09-19

beeline.purchase(230, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
beeline.purchase(250, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.purchase(373, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-20

beeline.send_transfer_to_person(26_500, 'Аренда') # перевод физическому лицу
beeline.purchase(445, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.purchase(648, MCC::GROCERY_STORES, 'Продукты')
cash.decrease(2_600, 'Абонемент на групповые занятия')
holder.next_day!

# => 2017-09-21

beeline.purchase(555, MCC::EATING_PLACES, 'Кафе или ресторан')
holder.next_day!

# => 2017-09-22

beeline.purchase(495, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
beeline.purchase(80, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-23

beeline.purchase(210, MCC::GROCERY_STORES, 'Продукты')
beeline.purchase(22, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-24

beeline.purchase(22, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# => 2017-09-25

beeline.purchase(456, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
beeline.purchase(599, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-26

beeline.purchase(510, MCC::EATING_PLACES, 'Кафе или ресторан')
beeline.purchase(332, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-27

beeline.purchase(250, MCC::EATING_PLACES, 'Киргизская кухня')
beeline.purchase(286, MCC::FAST_FOOD, 'Ресторан быстрого обслуживания')
holder.next_day!

# => 2017-09-28

beeline.purchase(169, MCC::GROCERY_STORES, 'Продукты')
beeline.purchase(846, MCC::GROCERY_STORES, 'Продукты')
holder.next_day!

# => 2017-09-29

beeline.purchase(235, MCC::EATING_PLACES, 'Киргизская кухня')
holder.next_day!

# => 2017-09-30

beeline.purchase(44, MCC::LOCAL_SUBURBAN, 'Билет на электричку')
holder.next_day!

# results

holder.put_log
# => table
# Date | Билайн | Сбербанк | Наличные | Sum
