#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 26 16:57:03 2019

@author: jean
"""
import numpy as np


def data_expand(x_data,y_data,order_in, order_out, n_in = 1):
    for i in range(order_in):
        for j in range(n_in):
            if i != 0:
                x_data_aux = np.concatenate((np.zeros([i,1]),x_data[:-i,j]),axis = 0)
                Data_x = np.concatenate((Data_x,x_data_aux),axis = 1)
            else:
                if j == 0:
                    Data_x = np.atleast_2d(x_data[:,j]).reshape(x_data.shape[0],1)
                else:
                    Data_x = np.concatenate(Data_x,x_data[:,j])
    for i in range(order_out):
        if i !=0:
            y_data_aux = np.concatenate((np.zeros([i+1,1]),y_data[:-(i+1)]),axis = 0)
            Data_y = np.concatenate((Data_y,y_data_aux),axis = 1)
        else:
            y_data_aux = np.atleast_2d(y_data[:-(i+1)]).reshape(y_data.size-1,1)
            Data_y =  np.concatenate((np.zeros([i+1,1]),y_data_aux),axis = 0)
    data = np.concatenate((Data_x,Data_y),axis = 1)  
    return data    

class arx:
    def __init__(self,order_in,order_out,n_in = 1):
        
        self.y_ant = np.zeros([order_out,1])
        self.x = np.zeros([order_in*n_in,1])
        self.weights = np.zeros([order_out + order_in,1])
        self.order_in = order_in
        self.order_out = order_out
        self.n_in = n_in
        
    def train(self,x_data,y_data,reg = 0.0):
        y_data = np.atleast_2d(y_data.reshape(y_data.size,1))
        x_data = np.atleast_2d(x_data.reshape(x_data.shape[0],self.n_in))
                
        data = data_expand(x_data,y_data,self.order_in,self.order_out,self.n_in)
            
            
        self.weights = np.linalg.solve(np.dot(data.T,data) + reg*np.eye(self.order_in + self.order_out),np.dot(data.T,y_data))
        
        
    def predict(self,u):
        u = np.atleast_2d(u)
        self.x = np.concatenate((u,self.x[:-self.n_in]))
        y = np.dot(self.weights.T,np.concatenate((self.x,self.y_ant)))
        self.y_ant = np.concatenate((y,self.y_ant[:-1]))
        return y
    
    def get_gain(self,n_in):
        
        return np.sum(self.weights[(n_in-1)*self.order_in:n_in*self.order_in])/np.sum(self.weights[self.order_out:])
    
 
    def get_weights(self):
        
        return self.weights
    
    def instrumental_train(self,x_data,y_data,reg = 0.0,num_iter_ins = 3):
        
        y_data = np.atleast_2d(y_data.reshape(y_data.size,1))
        x_data = np.atleast_2d(x_data.reshape(x_data.shape[0],self.n_in))
        data = data_expand(x_data,y_data,self.order_in,self.order_out,self.n_in)
            
            
        self.weights = np.linalg.solve(np.dot(data.T,data) + reg*np.eye(self.order_in + self.order_out),
                                       np.dot(data.T,y_data))
        
        
        y_data_arx =  np.empty_like(x_data)
        for j in range(num_iter_ins):
            for i in range(y_data.shape[0]):
                y_data_arx[i] = self.predict(x_data[i])
            
            data_z = data_expand(x_data,y_data_arx,self.order_in,self.order_out)
            self.weights = np.linalg.solve(np.dot(data_z.T,data) + reg*np.eye(self.order_in + self.order_out),
                                       np.dot(data_z.T,y_data))
        print self.weights, "esses são os pesos"
        
        
    def rls(self,ref,forget = 1.0):
        #ref e o vetor de todas as sa
        # idas desejados no dado instante de tempo.
        #calcular o vetor de erros
        e = np.dot(self.weights.T,np.concatenate((self.x,self.y_ant))) - ref

        #Transpose respective output view..

        #MQR equations

        #the P equation step by step
        A = self.P/forget
        B = np.dot(self.P,self.a)
        C = np.dot(B,self.a.T)
        D = np.dot(C,self.P)
        E = np.dot(self.a.T,self.P)
        G = np.dot(E,self.a)
        F = self.forget + G

        #final update
        self.P = A - D/(forget*F)


        #error calculation
        self.weights = self.weights - e[saida]*B
        