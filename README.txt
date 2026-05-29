====================================================
 Лабораторная работа №6 — Порядок запуска
====================================================

Все скрипты запускать из папки lab6/ на CentOS 8.

----------- Шаг 0: подготовка -----------

# Скопировать все .sh файлы в VM, дать права на выполнение:
chmod +x *.sh

# Установить gnuplot (для графиков):
sudo dnf install gnuplot -y

----------- Шаг 1: калибровка -----------

# Проверить, что одна задача занимает ~2-3 секунды:
bash calibrate.sh

# Если CPU-задача быстрее 2 сек — увеличить ITERS в compute.sh (строка ITERS=3000000)
# Если CPU-задача медленнее 3 сек — уменьшить ITERS
#
# Если дисковая задача быстрее 2 сек — увеличить DISK_LINES в run_all.sh (строка DISK_LINES=5000)
# Если дисковая задача медленнее — уменьшить DISK_LINES

----------- Шаг 2: эксперименты с 1 CPU -----------

# В настройках VM: установить 1 процессор, перезагрузить VM.

# Запустить все эксперименты (займёт долго: 20*10*4 измерений):
bash run_all.sh

# Результаты появятся в results/:
#   seq_cpu.dat — последовательные CPU-задачи
#   par_cpu.dat — параллельные CPU-задачи
#   seq_disk.dat — последовательные дисковые задачи
#   par_disk.dat — параллельные дисковые задачи

# Построить графики (seq vs par для 1 CPU):
bash plot.sh
# → results/graph_cpu_1cpu.png
# → results/graph_disk_1cpu.png

# Переименовать файлы для хранения результатов 1 CPU:
mv results/seq_cpu.dat  results/seq_cpu_1cpu.dat
mv results/par_cpu.dat  results/par_cpu_1cpu.dat
mv results/seq_disk.dat results/seq_disk_1cpu.dat
mv results/par_disk.dat results/par_disk_1cpu.dat

----------- Шаг 3: эксперименты с 2 CPU -----------

# В настройках VM: установить 2 процессора, перезагрузить VM.

# Снова запустить все эксперименты:
bash run_all.sh

# Переименовать для 2 CPU:
mv results/seq_cpu.dat  results/seq_cpu_2cpu.dat
mv results/par_cpu.dat  results/par_cpu_2cpu.dat
mv results/seq_disk.dat results/seq_disk_2cpu.dat
mv results/par_disk.dat results/par_disk_2cpu.dat

----------- Шаг 4: итоговые графики -----------

# Построить 4 сравнительных графика (1CPU vs 2CPU для каждого режима):
bash plot_compare.sh

# Результат:
#   results/graph1_seq_cpu.png   — Эксп. 1 и 3: CPU, последовательно
#   results/graph2_par_cpu.png   — Эксп. 1 и 3: CPU, параллельно
#   results/graph3_seq_disk.png  — Эксп. 2 и 4: Диск, последовательно
#   results/graph4_par_disk.png  — Эксп. 2 и 4: Диск, параллельно

====================================================
 Описание скриптов
====================================================

compute.sh      — CPU-алгоритм: вычисляет тяжёлую тригонометрическую сумму
                  (3 000 000 итераций с sin/cos через awk). Вход: seed (1..20).

disk_task.sh    — Дисковый алгоритм: читает числа из файла по одному,
                  умножает на 2, дописывает в конец файла (один write на значение).

seq_cpu.sh N    — Запускает N compute.sh последовательно
par_cpu.sh N    — Запускает N compute.sh параллельно (все сразу)
seq_disk.sh N   — Запускает N disk_task.sh последовательно (каждый на своём файле)
par_disk.sh N   — Запускает N disk_task.sh параллельно (каждый на своём файле)

prepare_files.sh — Создаёт 20 файлов data/file_1.txt..file_20.txt
reset_files.sh  — Восстанавливает файлы перед каждым измерением диска
calibrate.sh    — Измеряет время одной CPU и одной дисковой задачи
run_all.sh      — Главный скрипт: запускает все эксперименты, сохраняет .dat
plot.sh         — Строит 2 графика (seq vs par, текущие данные)
plot_compare.sh — Строит 4 итоговых графика (1CPU vs 2CPU)
