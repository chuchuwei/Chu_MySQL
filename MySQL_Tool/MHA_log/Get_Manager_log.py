# !/usr/bin/python
#-*-coding:utf8-*-
import datetime
import subprocess
# from Send_Email import SendEmail
import yagmail
output = subprocess.check_output(['tail','-n180','manager.log.txt'])
lines = output.split('\n')
words_list=['From','Disabling the VIP on old master',"Getting new master's binlog name and position"]
a = []
class SendEmail:
    def __init__(self,**kwargs):
        self.user=kwargs['user']
        self.password=kwargs['password']
        self.host=kwargs['host']
    def Sendemail(self):
        yag = yagmail.SMTP(user=self.user,password=self.password,host=self.host)
        content = ['检测到MHA发生了故障切换，详情见附件','out.txt']
        yag.send('cc08qb@163.com','AIA友邦故障告警',content)
        yag.close()
    def read_file(*args):
        for number,line in enumerate(lines):
            for words in args:
                if  words in line:
                    line_list = (lines[number:number+8])
                    line_str = '\n'.join(line_list)
                    f = open('out.txt', mode='a', encoding='utf-8')
                    e = f.write(line_str + '\n')
                    f.close()
                    line_time = datetime.datetime.strptime(lines[number+7][0:24],'%a %b %d %H:%M:%S %Y')
                    time_now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    time_now_datetime = datetime.datetime.strptime(time_now,'%Y-%m-%d %H:%M:%S')
                    a.append((time_now_datetime - line_time).total_seconds())
        print (a)
        for i in a:
            if i >=13860:
                Sendemail()

if __name__ == '__main__':
    parmas = {'user': '',
              'password': '',
              'host': 'smtp.jiagouyun.com'}
    re=SendEmail(**parmas)
    re.Sendemail()



