import { RouterModule } from '@angular/router';
import { DetailsComponent } from './details/details.component';
import { HttpClientModule } from '@angular/common/http';
import { StudentDetails } from '../core/models/student-details.model';
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StudentService } from '../core/services/student.service';

@NgModule({
  imports: [
    CommonModule,
    RouterModule,
    HttpClientModule
  ],
  declarations: [
    DetailsComponent
  ],
  providers: [StudentService]
})
export class StudentsModule { }
