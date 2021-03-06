# Generated by Django 2.0.7 on 2018-08-12 12:44

from django.db import migrations, models
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('ops', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='CeleryTask',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=1024)),
                ('status', models.CharField(choices=[('waiting', 'waiting'), ('running', 'running'), ('finished', 'finished')], max_length=128)),
                ('log_path', models.CharField(blank=True, max_length=256, null=True)),
                ('date_published', models.DateTimeField(auto_now_add=True)),
                ('date_start', models.DateTimeField(null=True)),
                ('date_finished', models.DateTimeField(null=True)),
            ],
        ),
    ]
