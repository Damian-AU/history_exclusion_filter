set plugin_name "history_exclusion_filter"
if {![info exist ::settings(history_exclusion_length]} {
    set ::settings(history_exclusion_length) 5
}

namespace eval ::plugins::${plugin_name} {
	variable author "Damian"
	variable contact "via Diaspora"
	variable version 1.1
	variable description "Exclude profile types Cleaning, Calibration, Testing, Test, or any profile that runs for less than the time set in the history_exclusion_filter settings from saving history files and adding to the espresso count"


	proc build_ui {} {
        # Unique name per page
        set page_name "history_exclusion_filter"
        dui page add $page_name
        set background_colour #d1d1d1
        set disabled_colour #ccc
        set foreground_colour #2b6084
        set button_label_colour #fAfBff
        set text_colour #2b6084
        set red #DA515E
        set green #0CA581
        set blue #49a2e8
        set brown #A1663A
        set orange #fe7e00
        set font "notosansuiregular"
        set font_bold "notosansuibold"



        dui add canvas_item rect $page_name 0 0 2560 1600 -fill $background_colour -width 0
        dui add dtext $page_name 1280 240 -text [translate "History Exclusion Filter"] -font [dui font get $font_bold 28] -fill $text_colour -anchor "center" -justify "center"

        dui add dtext $page_name 780 600 -text [translate "Minimum run time"] -font [dui font get $font_bold 22] -fill $text_colour -anchor w

        dui add variable $page_name 1440 600 -fill $text_colour -font [dui font get $font 22] -anchor center -textvariable {[round_to_integer $::settings(history_exclusion_length)]s}

        dui add dbutton $page_name 1270 550 \
            -bwidth 100 -bheight 100 \
            -label {-} -label_font [dui font get $font 24] -label_fill $text_colour -label_pos {0.5 0.5} \
            -command {::plugins::history_exclusion_filter::adjust_time -1}
        dui add dbutton $page_name 1510 550 \
            -bwidth 100 -bheight 100 \
            -label {+} -label_font [dui font get $font 24] -label_fill $text_colour -label_pos {0.5 0.5} \
            -command {::plugins::history_exclusion_filter::adjust_time 1}

        dui add dbutton $page_name 1080 1200 \
            -bwidth 400 -bheight 120 \
            -shape round -fill $foreground_colour -radius 60 \
            -label [translate "Exit"] -label_font [dui font get $font_bold 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {page_to_show_when_off extensions; save_settings}

    return $page_name
    }

	proc main {} {
        rename ::reset_gui_starting_espresso ::reset_gui_starting_espresso_hef
        proc ::reset_gui_starting_espresso {args} {
            ::reset_gui_starting_espresso_hef
            if {[espresso_elapsed_timer] <= $::settings(history_exclusion_length) || $::settings(beverage_type) == "Cleaning" || $::settings(beverage_type) == "Calibration" || $::settings(beverage_type) == "Test" || $::settings(beverage_type) == "Testing"} {
                set ::settings(espresso_count) [expr $::settings(espresso_count) - 1]
	            save_settings
            }
        }

        rename ::save_this_espresso_to_history ::save_this_espresso_to_history_hef
        proc ::save_this_espresso_to_history {unused_old_state unused_new_state} {
            if {[espresso_elapsed_timer] <= $::settings(history_exclusion_length) || $::settings(beverage_type) == "Cleaning" || $::settings(beverage_type) == "Calibration" || $::settings(beverage_type) == "Test" || $::settings(beverage_type) == "Testing"} {
                return
            }
            ::save_this_espresso_to_history_hef $unused_old_state $unused_new_state
        }

        plugins gui history_exclusion_filter [build_ui]
    }


    proc adjust_time {value} {
        set ::settings(history_exclusion_length) [round_to_one_digits [expr $::settings(history_exclusion_length) + $value]]
        if {$::settings(history_exclusion_length) < 1} {set ::settings(history_exclusion_length) 1}
        if {$::settings(history_exclusion_length) > 10} {set ::settings(history_exclusion_length) 10}

    }


}
