#!/bin/sh
# SPDX-License-Identifier: MIT

# NOTE: In case you found this and think it's a cool idea, think again.
# First of all, using output lines count as a progress metric is kinda
# stupid on it's own. I've added it there because it looks funny.
#
# Then, the interpreted code will run for every line and at least in this
# implementation it will take a bit of time. It seems insignificant for
# compile output where each "line" has some significant cpu time behind it,
# but if you put this after e.g. "tar -xv" with a large number of files,
# your unpack will become SUMB SLOW.
# 
# Beware.

progress_bar() {
	code='
	function zbar (cur, width) {
		width -= 2;
		printf "[";
		prog = (cur % (width*2));
		if (prog > (width))
			prog = width*2 - prog;
		for (i = 0; i < width; i++) {
			if (i == prog)
				printf "<=>";
			else
				printf " ";
		}
		printf "] %d", cur;
	}

	function pbar (cur, tot, width) {
		prog = int(width / tot * cur);
		pnote = sprintf("%d/%d", cur, tot);
		printf "[";
		for (i = 0; i < width; i++) {
			if (i == prog)
				printf ">";
			else if (i < prog)
				printf "=";
			else
				printf " ";
		}
		printf "] %s", pnote;
	}

	function bar (pref, cur, tot, cols) {
		width = cols - 45;
		printf "%-20s ", pref;
		if (tot == 0)
			zbar(cur, width);
		else
			pbar(cur, tot, width);
	}

	BEGIN { printf "\n"; }

	{
		"tput cols" | getline cols;
		close("tput cols");
		printf "\33[2K\r\033[A\33[2K\r";
		printf "%s", substr($0, 1, cols-5);
		gsub(/\t/, "  ");
		if (length($0) > cols-5)
			printf "...";
		printf "\n"
		bar(prefix, NR, tot_cnt, cols);
	}

	END {
		printf "\33[2K\r\033[A\33[2K\r";
		if (NR > 0) {
			bar(prefix, NR, tot_cnt, cols);
			printf "\n";
		}
	}
	'
	awk -v tot_cnt=$1 -v prefix="$2" "$code"
}

#test_prog() {
#	lcnt=120
#	for (( i = 0; i < $lcnt; i++ )); do
#		delay=$(printf '0.%04d\n' $(( ($RANDOM/20) )))
#		LC_NUMERIC="en_US.UTF-8" printf "dummy line %4d -> %.3f ===================================================\n" $i $delay
#		sleep $delay
#	done
#}
#test_prog | progress_bar 120
