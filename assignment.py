# Convert minutes
def convert_minutes(minutes):
    hrs = minutes // 60
    mins = minutes % 60
    if hrs == 0:
        return f"{mins} minutes"
    elif mins == 0:
        return f"{hrs} hrs"
    else:
        return f"{hrs} hrs {mins} minutes"


# Remove duplicates
def remove_duplicates(s):
    result = ""
    for char in s:
        if char not in result:
            result += char
    return result
