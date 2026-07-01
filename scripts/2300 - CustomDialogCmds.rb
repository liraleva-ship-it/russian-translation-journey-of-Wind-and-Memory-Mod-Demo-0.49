
$imported ||= {}
if not $imported["IDL-CustomDialogCmds"]
$imported["IDL-CustomDialogCmds"] = "1.0"

module CustomDialogCmds
	
	COMMANDS = {
		'T' => :cdc_escape_layout_text
	}
end

# Helper window for calculating size of message text
class CustomDialogCmds_Window < Window_Message

	def initialize(font)
		super()  # Window_Message#initialize takes no args; bare `super` would forward `font` -> ArgumentError
		contents.font = font
	end

	def process_normal_character(c, pos)
		text_width = text_size(c).width
		pos[:x] += text_width
	end
  
	def text_width_ex(x, y, text)
		reset_font_settings
		
		text.rstrip!
		pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
		process_character(text.slice!(0, 1), text, pos) until text.empty?
	
		return pos[:x]
	end
  
	# Ignore all wait commands
	def wait(num)
	end
	
	def input_pause
	end
	
	def input_choice
	end
		
	def input_number
	end
		
	def input_item
	end
end

class Window_Message < Window_Base

	alias cdc_orig_initialize initialize
	alias cdc_orig_process_escape_character process_escape_character

	def initialize
		cdc_orig_initialize
		cdc_add_custom_commands
	end

	def process_escape_character(code, text, pos)
		custom_escape = @escape_commands[code.upcase]
		return cdc_orig_process_escape_character(code, text, pos) unless custom_escape
		custom_escape.call(text, pos)
	end
	
	def cdc_add_custom_commands
		@escape_commands = {}
		
		default_commands = CustomDialogCmds::COMMANDS.each_with_object({}) do |(name, command), mem|
			mem[name] = method(command) if command.class == Symbol
		end
		@escape_commands.update(default_commands)
	end
	
	def cdc_obtain_escape_param_string(text)
		text.slice!(/^\[(.*?)\]/) && $1 || "" rescue ""
	end
	
	def cdc_text_ex_size(text)
		# copy text and grab first line
		line_text = text.split("\n")[0]
		return CustomDialogCmds_Window.new(contents.font).text_width_ex(0, 0, line_text)
	end
	
	def cdc_escape_layout_text(text, pos)
		parameter = cdc_obtain_escape_param_string(text)
		
		line_width = cdc_text_ex_size(text)
		prefix_width = 0
		
		case parameter.upcase
		when 'C' # center
			prefix_width = (contents.width - line_width) / 2
		when 'L' # left
			prefix_width = 0
		when 'R' # right
			prefix_width = (contents.width - line_width)
		else
			
		end
		
		pos[:x] = prefix_width
	end
end

end # not $imported["IDL-CustomDialogCmds"]