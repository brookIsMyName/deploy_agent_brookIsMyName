#!/bin/bash

handling_interruption() {
   echo
   echo "Deployment was suddenly stopped. creating a ZIP backup ... :)"

   if [[ -n "$directory" && -d "$directory" ]]; then
     # i learned that when using a variable in a string inside a function we need curly braces ..... the hard way :(
      archive="${directory}_archive.zip"

      if zip -r "$archive" "$directory"; then
          if rm -r "$directory"; then
              echo "Backup saved to $archive, also removed the project directory toooo"
          else
              echo "Couldnt remove the project directory"
          fi
     else
         echo "error when trying to zip up the backup."
     fi
   else
      echo "i didnt find a project directory with that name"
  fi
     trap - INT TSTP
     exit 1
}

# I first check if the two dependencies are installed

if command -v python3 >/dev/null 2>&1; then
   echo "Python3 is installed"
else
   echo "Python3 is not installed"
   exit 1
fi

if command -v zip >/dev/null 2>&1; then
   echo "zip is installed"
else
   echo "zip is not installed"
   exit 1
fi



# i display the menu to the user here so they can choose accordingly

echo "+++++++++ project deploymeny agent +++++++++"
echo "1. Deploy a new project"
echo "2. Run an existing project"
echo "3. Archive generated logs"
echo "4. Exit"



# I then ask for the user input

read -p "Please choose an option to continue: " choice



# I use case to execute different options based on what the user chooses


case "$choice" in
   1)
       read -p "what should the project name be: " name

       # i learnt that the -z operator disallows empty inputs so i use that here

       if [[ -z "$name" ]]; then
          echo  "Name cannot be empty"
          exit 1
       else
          directory="attendance_tracker_$name"
       fi

       # then i check whether or not the file exists already and if the user want to overwrite or not

       if [[ -e "$directory" ]]; then
          read -p "Directory already exists. Do you want to overwrite (y/n) " overwrite
         case "$overwrite" in
           y)

              # if the user responds with yes then i deleted the existing folder create it newly and copy the starter files into it
 
              # these two are used two check if the starter files exist or not

              if [[ -f "templates/attendance_checker.py" ]]; then
                     echo "attendance template found"
              else
                     echo "attendance_checker.py is missing"
                     exit 1
              fi


              if [[ -f "templates/config.json" ]]; then
                     echo "config template found"
              else
                     echo "config.json template not found"
                     exit 1
              fi


              trap 'handling_interruption' INT TSTP
              if rm -r "$directory"; then
                  echo "Old directory removed"

              else
                  echo "Could not remove the old directory"
                  exit 1
              fi
              if mkdir "$directory"; then
                  echo "Directory created successfully"

                  if mkdir -p "$directory/Helpers" "$directory/reports"; then
                     echo "parent folders created successfully"
                  else
                     echo "could not create parent folders"
                     exit 1
                  fi
                  # these two are used two check if the starter files exist or not

                  if [[ -f "templates/attendance_checker.py" ]]; then
                     echo "attendance template found"
                  else
                     echo "attendance_checker.py is missing"
                     exit 1
                  fi
                  if [[ -f "templates/config.json" ]]; then
                     echo "config template found"
                  else
                     echo "config.json template not found"
                     exit 1
                  fi

                  # then if they exist i copy them and display a success message :)

                  if cp templates/attendance_checker.py "$directory/attendance_checker.py"; then
                     echo "attendance_checker successfully copied into root directory"
                  else
                     echo "Error while copying attendance_checker.py"
                     exit 1
                  fi

                  if cp templates/config.json "$directory/Helpers/config.json"; then
                     echo "config file copied succesfully into root directory"
                  else
                     echo "Error while copying config.json"
                     exit 1
                  fi

              else
                  echo "could not created directory"
                  exit 1
              fi
              ;;
           n)
              echo "Directory not overwritten."
              exit 0
              ;;
           *)
              echo "Invalid Input"
              exit 1
              ;;
         esac
       else

           # if a directory name with the user input doesnt exist already this command executes
           trap 'handling_interruption' INT TSTP
           if mkdir "$directory"; then
              echo "Created a new directory successfully"
              mkdir -p "$directory/Helpers" "$directory/reports"

              # I also check whether the files exist in this scenario too.


              if [[ -f "templates/attendance_checker.py" ]]; then
                     echo "attendance template found"
              else
                     echo "attendance_checker.py is missing"
                     exit 1
              fi
              if [[ -f "templates/config.json" ]]; then
                     echo "config template found"
              else
                     echo "config.json template not found"
                     exit 1
              fi

              # and like usual if they exist I copy them into the root directory


              if cp templates/attendance_checker.py "$directory/attendance_checker.py"; then
                 echo "attendance_checker successfully copied into root directory"
              else
                 echo "Error while copying attendance_checker.py"
                 exit 1
              fi

              if cp templates/config.json "$directory/Helpers/config.json"; then
                 echo "config file copied succesfully into root directory"
              else
                 echo "Error while copying config.json"
                 exit 1
              fi
           else
              echo "could not created directory"
              exit 1
           fi
       fi

       read -p "Choose roster type (A: existing students, B: fresh roster): " roster_choice
       case "$roster_choice" in
          A)
              read -p "How many existing students data should be copied from your existing roster: " student_count

             # here i tried to make sure that the user input can neverrr be negative :)

              if [[ "$student_count" =~ ^[1-9][0-9]*$ ]]; then
                 echo "Valid student count"
                 if [[ "$student_count" -le 4 ]]; then
                     echo "Student count is within the available range"
                 else
                     echo "Only 4 student records are available"
                     exit 1
                 fi
              else
                 echo "Please enter a positive whole number"
                 exit 1
              fi

              # then i copied the lines the user requested plus 1 more


              if head -n "$((student_count + 1))" templates/assets.csv > "$directory/Helpers/assets.csv"; then
                 echo "Copied $student_count data"
              else
                 echo "error copying from existing roster"
              fi
              ;;
          B)
              # here i just used dummy emails and names that get written to the file and looped through them
              names=("Alice Johnson" "Bob Smith" "Charlie Davis")
              emails=("alice@example.com" "bob@example.com" "charlie@example.com")
              echo "Email,Names,Attendance Count,Absence Count" > "$directory/Helpers/assets.csv"
              for i in "${!names[@]}"; do
                  echo "${emails[$i]},${names[$i]},0,0" >> "$directory/Helpers/assets.csv"
              done
              ;;
          *)
              echo "Invalid roster choice selected"
              exit 1
              ;;
       esac


      # I modified the permissions of config and attendance checker using the simple chmod command

       if chmod +x "$directory/attendance_checker.py"; then
          echo "file permission modified to executable state"
       else
          echo "Error trying to make file executable"
       fi
       if chmod 600 "$directory/Helpers/config.json"; then
          echo "config.json set to RW permission for owner"
       else
          echo "Error changing permissions for config.json"
       fi


      # made a system that can update the warning and failure threshold based on the users input

       read -p "Enter warning threshold from 0-100: " warning
       if [[ "$warning" =~ ^[0-9]+$ ]] && (( warning <= 100 )); then
           echo "Valid warning threshold"
       else
           echo "Warning threshold must be a number between 0 and 100"
           exit 1
       fi
            # i can easily update the value using sed in both :)
       sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$directory/Helpers/config.json"

       read -p "Enter failure threshold from 0-100. It must be less than the warning threshold: " failure
       if [[ "$failure" =~ ^[0-9]+$ ]] && (( failure <= 100 )) && ((failure < warning)); then
           echo "Valid failure threshold"
       else
           echo "Invalid number"
           exit 1
       fi

       sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$directory/Helpers/config.json"

       trap - INT TSTP
       ;;
   2)
       echo "Run selected"
       read -p "Enter the project name: " name
       directory="attendance_tracker_$name"

       if [[ -d "$directory" && -f "$directory/attendance_checker.py" ]]; then
          echo "Running project $name.... :)"
          (cd "$directory" && python3 attendance_checker.py)
       else
          echo "either the Project or attendance_checker.py is missing!"
          exit 1
       fi
       ;;
   3)
       echo "Archive selected"
       read -p "Enter your projects name: " name
       directory="attendance_tracker_$name"

       if [[ ! -d "$directory" ]]; then
          echo "Project directory not found"
          exit 1
       fi
       mkdir -p "$directory/archives/attendance" "$directory/archives/absent"
       # i used the syntax that i found online to calculate the date to the exact second and save it as a variable called timestamp
       timestamp=$(date +%Y%m%d_%H%M%S)

       if [[ -f "$directory/reports/attendance.log" ]]; then
          if cp "$directory/reports/attendance.log" "$directory/archives/attendance/attendance_$timestamp.log"; then
              echo "Attendance log archived successfully"
          else
              echo "something went wrong while trying to copy the archived logs"
          fi
      else
           echo "the log file itself may not existtt"
      fi
       ;;
   4)
       echo "Goodbyeee"
       exit 0
       ;;
   *)
       echo "Invalid option selected"
       ;;
esac

