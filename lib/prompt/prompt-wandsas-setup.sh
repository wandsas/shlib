
# color: http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
function prompt_wandsas_setup {
	local TTY=$(tty | cut -b6-) uc
	case "${EUID}" in
		(0) uc="${fg[1]}";;
		(*) uc="${fg[2]}";;
	esac
	PS1="\[${color[bold]}${fg[5]}\]-\[${fg[4]}\](\[${uc}\]\$·\[${fg[5]}\]\h:${TTY}\[${fg[4]}\]·\D{%m/%d}·\[${fg[5]}\]\A\[${fg[4]}\])-\[${fg[2]}\]»\[${color[none]}\] "
	PS2="\[${color[bold]}${fg[5]}\]-\[${fg[2]}\]» \[${color[none]}\]"
	PROMPT_DIRTRIM=3
	TITLEBAR="\$:\w"
}

PROMPT_COMMAND="prompt_wandsas_setup; $PROMPT_COMMAND"
