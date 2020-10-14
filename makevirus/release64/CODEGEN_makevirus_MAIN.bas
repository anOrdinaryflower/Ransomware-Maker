'-----------------------------------------------------------------------------
' �� VisualFreeBasic 5.2.8 ���ɵ�Դ����
' ����ʱ�䣺2020��05��11�� 09ʱ00��40��
' ������Ϣ����� www.yfvb.com 
'-----------------------------------------------------------------------------


Dim Shared ansiStr_CodePage As ULong = 936  'Ĭ��A�ַ�����ҳ�����ڲ�ͬ����ϵͳ֮�����������ʾ�ַ���
Dim Shared String_CharSet As ULong =1
Sub Setup_ansiStr_CodePage(cd As uLong) '���ô���ҳ
   ansiStr_CodePage = cd
   '��ȡ FB ���ú�������ҳ����λ�á�
   Dim As Any Ptr library = DyLibLoad( "Kernel32" )
   If (library = 0) Then Return
   Dim xxFlsGetValue As Function(ByVal eID As Integer) As UInteger
   xxFlsGetValue = DyLibSymbol(library, "FlsGetValue")
   Dim py As Long, ff As UInteger
   If (xxFlsGetValue = 0) Then
      xxFlsGetValue = DyLibSymbol(library, "TlsGetValue")
      ff = xxFlsGetValue(1)
      If ff = 0 Or ff = xxFlsGetValue Then Return  '��ʱ XP �� TlsGetValue����ʱ�Լ�������ַ��
      'XP ϵͳ
      ff += &H64
   Else  'XP�Ժ��ϵͳ
      ff = xxFlsGetValue(1)
      If ff = 0 Then Return
      ff += IIf(Len(UInteger) = 4, &H6C,&HB8)  '64λ��32λ
   End if
   If ff = 0 Then Return
   ff = Peek(UInteger, ff) + 4
    *CPtr(uLong Ptr, ff) = cd
   DyLibFree(library)
End Sub
Setup_ansiStr_CodePage(936) '���ô���ҳ

'[START_APPSTART]
'************ Ӧ�ó�����ʼģ�� ************
' �����Ǵ�����������ִ�д���ĵط�����ʱ����ڲ���δ��ʼ������ע��һ�����EXE����DLL�ģ�DLL����EXEִ��DLL�Լ�����ʼ���룩
' ������EXE����DLL���������￪ʼִ�У�Ȼ�󵽡�������ں�����ִ�У��������������DLL��ж�ؾ�ִ�С�������ڡ����̡�(�����EXE��DLL��ʾ�Լ�����)
' һ�����������д DLL �������Զ���������������#Include�İ����ļ������ںܶ��ʼ������δִ�У����ﲻ����д�û����롣

#define UNICODE                 '��ʾWIN��APIĬ��ʹ�� Wϵ�У����ַ��������ɾ����ʹ��ASCII�ַ�������ɿؼ���APIʹ�õĴ����д��ʽ��Ӱ����Զ��
#lang "FB"                      '��ʾΪ��׼FB��ʽ
#include Once "windows.bi"      'WINϵͳ�����⣬��Ҫ��WINϵͳ���õ�API����ʹ��API���Բ���������
#include Once "win/shlobj.bi"   'WINϵͳ����⣬shell32.dll��ͷ�ļ�����Ҫ�漰shell��ͨ�öԻ���ȡ�
#include Once "afx/CWindow.inc" 'WinFBX �⣬��WINϵͳ��ǿ�����⣬ʹ�ô��ںͿؼ�����Ҫ�õ�����
#include Once "vbcompat.bi"     'һЩ����VB�����ͳ������������ͻ��޷�ʹ�������ˡ�
#include Once "fbthread.bi"     'VisualFreeBasic�߳����֧�ֿ⣬Ҫ���߳���䣬�ͱ��������

'���� �����ļ� ��Ӱ�����ձ��������ļ��Ĵ�С��������Ӱ������Ч�ʣ������ļ���С�Ƚ����еģ����Ը�����Ҫ������



'[END_APPSTART]

#include Once "win/shlobj.bi"   'WINϵͳ����⣬shell32.dll��ͷ�ļ�����Ҫ�漰shell��ͨ�öԻ���ȡ�
' ����Ա����ͨ������APP�������ʵĹ�����Ϣ��
Type APP_TYPE
   Comments        As  CWSTR      ' ע��
   CompanyName     As  CWSTR       ' ��˾�� 
   EXEName         As  CWSTR      ' �����EXE���� 
   FileDescription As  CWSTR       ' �ļ����� 
   hInstance       As  HINSTANCE                ' �����ʵ�����
   Path            As  CWSTR      ' EXE�ĵ�ǰ·��
   ProductName     As  CWSTR      ' ��Ʒ���� 
   LegalCopyright  As  CWSTR       ' ��Ȩ���� 
   LegalTrademarks As  CWSTR     ' �̱�
   ProductMajor    As Long                    ' ��Ʒ��Ҫ��� 
   ProductMinor    As Long                    ' ��Ʒ��Ҫ���   
   ProductRevision As Long                    ' ��Ʒ�޶���
   ProductBuild    As Long                    ' ��Ʒ�ڲ����   
   FileMajor       As Long                    ' �ļ���Ҫ���     
   FileMinor       As Long                    ' �ļ���Ҫ���     
   FileRevision    As Long                    ' �ļ��޶���  
   FileBuild       As Long                    ' �ļ��ڲ����     
   ReturnValue     As Integer                 ' ���ص��û�ֵ
End Type
Dim Shared App As APP_TYPE
Sub Setting_up_Application_Common_Information()
   '���ù���Ӧ�ó��������ֵ
   #if __FB_OUT_EXE__
   App.hInstance = GetModuleHandle(null)
   #else
   Dim mbi as MEMORY_BASIC_INFORMATION
   VirtualQuery(@Setting_up_Application_Common_Information, @mbi, SizeOf(mbi))
   App.hInstance = mbi.AllocationBase
   #endif
   Dim zTemp As WString * MAX_PATH
   Dim x As Long
   App.CompanyName = ""
   App.FileDescription = ""
   App.ProductName = ""
   App.LegalCopyright = ""
   App.LegalTrademarks = ""
   App.Comments = ""
   
   App.ProductMajor = 1
   App.ProductMinor = 0
   App.ProductRevision = 0
   App.ProductBuild = 0
   
   App.FileMajor = 1
   App.FileMinor = 0
   App.FileRevision = 0
   App.FileBuild = 57
   
   'App.hInstance ��WinMain / LibMain������
   
   '������������·���� EXE/DLL ����
   GetModuleFileNameW App.hInstance, zTemp, MAX_PATH
   x = InStrRev(zTemp, Any ":/\")
   If x Then
      App.Path = Left(zTemp, x)
      App.EXEname = Mid(zTemp, x + 1)
   Else
      App.Path = ""
      App.EXEname = zTemp
   End If
End Sub
Setting_up_Application_Common_Information
' ����/��ͬ ��Ŀ�е����к��������Ϳؼ�
#Include Once "CODEGEN_makevirus_DECLARES.inc"
#Include Once "CODEGEN_makevirus_UTILITY.inc"
#Include Once "CODEGEN_makevirus_mv_FORM.inc"
    

'[START_WINMAIN]
Function FF_WINMAIN(ByVal hInstance As HINSTANCE) As Long '������ں���
   'hInstance EXE��DLL��ģ�������������ڴ��еĵ�ַ��EXE ͨ���̶�Ϊ &H400000  DLL һ�㲻�̶� 
   '����Ϊ LIB��̬��ʱ�����������κ��ô� 
   ' -------------------------------------------------------------------------------------------
   '  DLL ���� ********  �������践��ֵ
   '  DLL�����ص��ڴ�ʱ����Ҫִ��̫��ʱ��Ĵ��룬����Ҫ��ʱ���ö��̡߳�
   '        AfxMsg "DLL�����ص��ڴ�ʱ"
   ' -------------------------------------------------------------------------------------------
   '  EXE ���� ********   
   '        AfxMsg "EXE������"
   ' ��������������TRUE�����㣩�������������������û���������ڣ���ô�˺�������Ҳ����ֹ�����
   ' �������ڴ˺����������ʼ����
   ' -------------------------------------------------------------------------------------------
   ' (�����EXE��DLL��ʾ�Լ������޷���ȡ����EXE��DLL��ںͳ���)

   Function = False   
End Function

Sub FF_WINEND(ByVal hInstance As HINSTANCE) '������ڣ�������ֹ��������롣
   'hInstance EXE��DLL��ģ�������������ڴ��еĵ�ַ��EXE ͨ���̶�Ϊ &H400000  DLL һ�㲻�̶� 
   '����Ϊ LIB��̬��ʱ�����������κ��ô� 
   ' -------------------------------------------------------------------------------------------
   '  DLL ���� ********    
   '    ж��DLL��DLL��ж�أ���Ҫ������ɣ������ý�������
   '    AfxMsg "DLL��ж��ʱ" 
   ' -------------------------------------------------------------------------------------------
   '  EXE ���� ********   
   '   ���򼴽����������������Ҫִ�еĴ��룬�����޷�ֹͣ���˳������ˡ�
   '      AfxMsg "EXE�˳�"
   ' -------------------------------------------------------------------------------------------
   ' (�����EXE��DLL��ʾ�Լ������޷���ȡ����EXE��DLL��ںͳ���)

End Sub



'[END_WINMAIN]


'[START_PUMPHOOK]
Function FF_PUMPHOOK( uMsg As Msg ) As Long '��Ϣ����
   '���д�����Ϣ��������������������������Ϣ��

   ' �������������� FALSE���㣩����ô VisualFreeBasic ��Ϣ�ý��������С�
   ' ���� TRUE�����㣩���ƹ���Ϣ�ã�������Ϣ�������ǳԵ�����Ϣ�������ںͿؼ�����
   ' 

   Function = False    '�������Ҫ������Ϣ������ TRUE ��

End Function



'[END_PUMPHOOK]


Function FLY_Win_Main(ByVal hInstance As HINSTANCE) As Long

      Dim gdipToken As ULONG_PTR
   Dim gdipsi As GdiplusStartupInput
   gdipsi.GdiplusVersion = 1
   GdiplusStartup( @gdipToken, @gdipsi, Null )

   ' ���� FLY_WinMain()������ ����ú�������True����ִֹͣ�иó���
   If FF_WINMAIN(hInstance) Then Return True
   ' �����������塣
   mv.Show 0, TRUE
   #if __FB_OUT_EXE__ 
   GdiplusShutdown( gdipToken )
   #endif 
   Function = 0
End Function
Public Sub WinMainsexit() Destructor
   FF_WINEND(App.hInstance)
End Sub
FLY_Win_Main( App.hInstance )




