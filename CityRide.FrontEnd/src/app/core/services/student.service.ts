import { StudentDetails } from '../models/student-details.model';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { HttpClient, HttpHeaders } from '@angular/common/http';

import { environment } from "../../../environments/environment";

@Injectable()
export class StudentService {

  private studentUrl = `${environment.apiUrl}/students/ad2da528-b0d9-45eb-35e3-08d5aa91685d`;

  constructor(private http: HttpClient) { }

  getStudent(): Observable<StudentDetails> {
    return this.http.get<StudentDetails>(this.studentUrl);
  }
  

}
