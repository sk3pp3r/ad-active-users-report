###########################################################
#    GET ACTIVE USERS REPORT  
#    This script generates a powershell report for Users:  
#       enable == true 
#       PasswordNeverExpires == false
# 
#   Haim Cohen 
#   July 01, 2019
#   https://github.com/sk3pp3r/get-active-users 
#   https://www.linkedin.com/in/haimc/
#   Version 1.0
###########################################################

$activeusers = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |Where-Object {$_.Enabled -eq "True"} | Where-Object { $_.PasswordNeverExpires -eq $false }
#  HTML & CSS
$css = @" 
<style>
h1, h5, th { text-align: center; font-family: Yu Gothic; }
table { margin: auto; font-family: Yu Gothic; box-shadow: 10px 10px 5px #888; border: 1px solid black; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@

$body = @"
<p style="text-align: left;"><strong>Hello IT Team,</strong></p>
See below a report of active users in $env:USERDNSDOMAIN
<hr>
"@

$status = $activeusers.count

$MailParameters = @{
                Subject = "$status Active Users in Domain $env:USERDNSDOMAIN - $((Get-Date).ToShortDateString())"
                Body = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |Where-Object {$_.Enabled -eq "True"} | Where-Object { $_.PasswordNeverExpires -eq $false } |
                Select-Object Name, EmailAddress, Enabled, PasswordLastSet, PasswordExpired |
                Sort-Object Name |
                ConvertTo-Html -Head $css -Body $body -post "<strong>Haim Cohen 2019 &copy</strong>" |
                Out-String
                From = "Active-Directory.Status@mydomain.com"
                To = "team01@mydomin.com"
                SmtpServer = "smtp"
				BodyAsHTML = $true
            }
    

Send-MailMessage @MailParameters 
