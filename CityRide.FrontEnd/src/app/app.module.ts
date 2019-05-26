import { RegisterService } from './core/services/register/register.service';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';
import { StudentService } from './core/services/student.service';
import { StudentsModule } from './student/students.module';
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';


import { AppComponent } from './app.component';
import { DetailsComponent } from './student/details/details.component';
import { LoginComponent } from './authentification/login/login.component';
import { RegisterComponent } from './authentification/register/register.component';

const appRoutes: Routes = [
  {
    path: 'welcome',
    component: DetailsComponent
  },
  {
    path:'login',
    component: LoginComponent
  },
  {
    path:'register',
    component: RegisterComponent
  },
  {
    path: '',
    redirectTo: 'welcome',
    pathMatch: 'full'
  }
];
@NgModule({
  declarations: [
    AppComponent,
    DetailsComponent,
    LoginComponent,
    RegisterComponent
  ],
  imports: [
    BrowserModule,
    RouterModule.forRoot(appRoutes),
    HttpClientModule,
    FormsModule 
  ],
  providers: [
    StudentService,
    RegisterService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
