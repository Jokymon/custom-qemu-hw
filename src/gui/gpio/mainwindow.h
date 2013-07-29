#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTcpServer>
#include <QTcpSocket>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

public slots:
    void on_about();
    void on_start();
    void on_stop();
    void on_acceptconnection();
    void on_clientread();
    void on_disconnected();

private:
    Ui::MainWindow *ui;
    QTcpServer * tcpserver;
    QTcpSocket * tcpclient;
};

#endif // MAINWINDOW_H
